package main

import (
	"fmt"
	"html/template"
	"net/http"
	"os"
)

func main() {
	http.HandleFunc("/", func(w http.ResponseWriter, r *http.Request) {
		tmpl, err := template.ParseFiles("index.html")
		if err != nil {
			http.Error(w, "template parse error", http.StatusInternalServerError)
			fmt.Fprintf(os.Stderr, "Unable to Parse File: %s\n", err)
			return
		}

		type TemplateData struct {
			Hostname string
		}

		hostname, err := os.Hostname()
		if err != nil {
			fmt.Fprintf(os.Stderr, "Unable to Read Hostname: %s\n", err)
		}

		if err = tmpl.Execute(w, TemplateData{Hostname: hostname}); err != nil {
			fmt.Fprintf(os.Stderr, "Unable to Templatize Values: %s\n", err)
		}
	})

	if err := http.ListenAndServe(":8080", nil); err != nil {
		fmt.Fprintf(os.Stderr, "Unable to start server: %s\n", err)
	}
}

