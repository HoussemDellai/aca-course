package album

import (
	"album-service/models"
	"encoding/json"
	"fmt"
	"net/http"
)

func init() {
	fmt.Println("Initialize - album package")
}

// Get function
func Get(w http.ResponseWriter, r *http.Request) {

	// serialize data
	j, _ := json.Marshal(models.GetAlbums())

	// set response
	w.Header().Set("Content-Type", "application/json")
	w.Write(j)
}