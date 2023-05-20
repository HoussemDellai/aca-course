package models

import (
	"fmt"
)

func init() {
	fmt.Println("Initialize - models package")
}

type Album struct {
	Id     		int  		`json:"id"`
	Title  		string  	`json:"title"`
	Artist 		string  	`json:"artist"`
	Price  		float64 	`json:"price"`
	Image_URL  	string 		`json:"image_url"`
}

func GetAlbums() []Album {

	var albums []Album

	album1 := Album{Id: 1, Title: "You, Me and an App ID", Artist: "Daprize", Price: 56.99, Image_URL: "https://aka.ms/albums-daprlogo"}
	albums = append(albums, album1)

	album2 := Album{Id: 2, Title: "Seven Revision Army", Artist: "The Blue-Green Stripes", Price: 39.99, Image_URL: "https://aka.ms/albums-containerappslogo"}
	albums = append(albums, album2)

	album3 := Album{Id: 3, Title: "Scale It Up", Artist: "KEDA Club", Price: 17.99, Image_URL: "https://aka.ms/albums-kedalogo"}
	albums = append(albums, album3)

	album4 := Album{Id: 4, Title: "Lost in Translation", Artist: "MegaDNS", Price: 39.99, Image_URL: "https://aka.ms/albums-envoylogo"}
	albums = append(albums, album4)

	album5 := Album{Id: 5, Title: "Lock Down Your Love", Artist: "V is for VNET", Price: 39.99, Image_URL: "https://aka.ms/albums-vnetlogo"}
	albums = append(albums, album5)

	album6 := Album{Id: 6, Title: "Sweet Container O' Mine", Artist: "Guns N Probeses", Price: 29.99, Image_URL: "https://aka.ms/albums-containerappslogo"}
	albums = append(albums, album6)

	return albums

};