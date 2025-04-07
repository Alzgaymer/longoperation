package main

import (
	"encoding/json"
	"fmt"
	"github.com/google/uuid"
	"go.mongodb.org/mongo-driver/v2/bson"
	"go.mongodb.org/mongo-driver/v2/mongo"
	"go.mongodb.org/mongo-driver/v2/mongo/options"
	"go.mongodb.org/mongo-driver/v2/mongo/readpref"
	"golang.org/x/net/context"
	"log"
	"log/slog"
	"net/http"
	"os"
	"strconv"
	"time"
)

const fmtConnString = "mongodb+srv://%s:%s@cl0.rgx0lpn.mongodb.net/?retryWrites=true&w=majority&appName=cl0"

func main() {
	slog.Info("Long Operation server starting...")

	client := ConnectMongoOrDie()
	defer client.Disconnect(context.Background())

	http.Handle("POST /api/v1/operations", createOperation(client))
	http.Handle("GET /api/v1/operations/{id}", getOperation(client))
	http.HandleFunc("GET /health", healthCheck)

	port := "80"
	if envPort := os.Getenv("PORT"); envPort != "" {
		port = envPort
	}

	slog.Info("Started server", "port", port)
	slog.Error("server error", http.ListenAndServe(":"+port, nil))
}

func ConnectMongoOrDie() *mongo.Client {
	serverAPI := options.ServerAPI(options.ServerAPIVersion1)

	credsStr := os.Getenv("MONGODB_CREDENTIALS")

	slog.Debug("Retrieving MongoDB credentials", "creds", credsStr)

	type MongoCredentials struct {
		Username string `json:"username"`
		Password string `json:"password"`
	}

	var creds MongoCredentials
	err := json.Unmarshal([]byte(credsStr), &creds)
	if err != nil {
		log.Fatal("mapping credentials", err)
	}

	uri := fmt.Sprintf(fmtConnString, creds.Username, creds.Password)

	slog.Info("Connecting to MongoDB", "uri", uri)

	opts := options.Client().SetServerAPIOptions(serverAPI).ApplyURI(uri)
	client, err := mongo.Connect(opts)
	if err != nil {
		log.Fatal(err)
	}

	if err = client.Ping(context.Background(), readpref.Primary()); err != nil {
		log.Fatal(err)
	}

	slog.Info("Connected to MongoDB")

	return client
}

func healthCheck(w http.ResponseWriter, r *http.Request) { return }

func createOperation(client *mongo.Client) http.HandlerFunc {
	coll := client.Database("test").Collection("operations")
	type Request struct {
		WaitFor int64 `json:"wait-for"`
	}

	var upsert = options.UpdateOne().SetUpsert(true)

	return func(w http.ResponseWriter, r *http.Request) {
		var req Request
		err := json.NewDecoder(r.Body).Decode(&req)
		if err != nil {
			http.Error(w, err.Error(), http.StatusBadRequest)
			slog.Error("decode request", err)
			return
		}

		operationID := uuid.NewString()
		_, err = coll.UpdateOne(
			context.Background(),
			bson.M{"_id": operationID},
			bson.M{
				"$set": bson.D{
					{"_id", operationID},
					{"wait-for", req.WaitFor},
					{"status", "NotStarted"}},
				"$currentDate": bson.M{
					"created_at": bson.M{"$type": "date"},
				}},
			upsert,
		)
		if err != nil {
			slog.Error("insert operation", err)
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.Header().Set("Operation-Location", fmt.Sprintf("/api/v1/operations/%s", operationID))
		w.Header().Set("Operation-ID", operationID)
		w.Header().Set("Retry-After", strconv.Itoa(int(req.WaitFor)))
		w.WriteHeader(http.StatusAccepted)
		_, _ = w.Write([]byte(fmt.Sprintf(`{"id": "%s"}`, operationID)))

		go func() {
			time.Sleep(time.Duration(req.WaitFor) * time.Second)
			_, err = coll.UpdateByID(context.Background(), operationID, bson.D{
				{"$set", bson.D{
					{"status", "Finished"},
				}},
				{"$currentDate", bson.D{
					{"updated_at", true},
				}},
			})
			if err != nil {
				slog.Error("update operation", err)
			}
		}()
	}
}

func getOperation(client *mongo.Client) http.HandlerFunc {
	coll := client.Database("test").Collection("operations")
	type Response struct {
		ID        string     `json:"id" bson:"_id"`
		Status    string     `json:"status" bson:"status"`
		CreatedAt time.Time  `json:"created_at" bson:"created_at"`
		UpdatedAt *time.Time `json:"updated_at,omitempty" bson:"updated_at,omitempty"`
	}

	return func(w http.ResponseWriter, r *http.Request) {
		id := r.PathValue("id")

		result := coll.FindOne(context.Background(), bson.M{"_id": id})
		if result.Err() != nil {
			http.Error(w, result.Err().Error(), http.StatusNotFound)
			return
		}

		var data Response
		err := result.Decode(&data)
		if err != nil {
			http.Error(w, err.Error(), http.StatusInternalServerError)
			return
		}

		w.Header().Set("Content-Type", "application/json")
		w.WriteHeader(http.StatusOK)
		marshal, _ := json.Marshal(data)
		_, _ = w.Write(marshal)
	}
}
