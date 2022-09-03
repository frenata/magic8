package main

import (
	"fmt"
	"net/http"
)

func eight_ball(w http.ResponseWriter, req *http.Request) {
	fmt.Fprintf(w, "The magic 8 ball says: ")
}

func main() {
	http.HandleFunc("/", eight_ball)

	http.ListenAndServe(":8080", nil)
}
