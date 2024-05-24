package main

import (
	"log/slog"
	"net/http"
	"net/http/httptest"
	"os"
	"testing"
)

func TestHealthcheckHandler(t *testing.T) {
	// Create an instance of our application struct
	app := &application{
		config: config{
			port: 4000,
			env:  "development",
		},
		logger: slog.New(slog.NewTextHandler(os.Stdout, nil)),
	}

	// Create a request to pass to our handler
	req, err := http.NewRequest("GET", "/v1/healthcheck", nil)
	if err != nil {
		t.Fatal(err)
	}

	// Create a ResponseRecorder to record the response
	rr := httptest.NewRecorder()
	handler := http.HandlerFunc(app.healthcheckHandler)

	// Serve the request to the handler
	handler.ServeHTTP(rr, req)

	// Check the status code is what we expect
	if status := rr.Code; status != http.StatusOK {
		t.Errorf("handler returned wrong status code: got %v want %v", status, http.StatusOK)
	}

	// Check the response body is what we expect
	expected := "status: availableenvironment: development\nversion: 1.0.0\n"
	if rr.Body.String() != expected {
		t.Errorf("handler returned unexpected body: got %v want %v", rr.Body.String(), expected)
	}
}
