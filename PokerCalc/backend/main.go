package main

import (
	"encoding/json"
	"fmt"
	"log"
	"net/http"
	"pokercalc/poker"
)

type BestHandRequest struct {
	Hole      []string `json:"hole"`
	Community []string `json:"community"`
}

type HandEvalResponse struct {
	RankName  string   `json:"rank_name"`
	Rank      int      `json:"rank"`
	BestCards []string `json:"best_cards"`
}

type ComparePlayerInput struct {
	Hole      []string `json:"hole"`
	Community []string `json:"community"`
}

type CompareRequest struct {
	Player1 ComparePlayerInput `json:"player1"`
	Player2 ComparePlayerInput `json:"player2"`
}

type CompareResponse struct {
	Winner      int              `json:"winner"`
	Player1Eval HandEvalResponse `json:"player1_eval"`
	Player2Eval HandEvalResponse `json:"player2_eval"`
}

type ProbRequest struct {
	Hole        []string `json:"hole"`
	Community   []string `json:"community"`
	NumPlayers  int      `json:"num_players"`
	Simulations int      `json:"simulations"`
}

func enableCORS(w http.ResponseWriter) {
	w.Header().Set("Access-Control-Allow-Origin", "*")
	w.Header().Set("Access-Control-Allow-Methods", "POST, GET, OPTIONS, PUT, DELETE")
	w.Header().Set("Access-Control-Allow-Headers", "Accept, Content-Type, Content-Length, Accept-Encoding, X-CSRF-Token, Authorization")
}

func mapEvalResponse(eval poker.HandEval) HandEvalResponse {
	cards := make([]string, len(eval.Cards))
	for i, c := range eval.Cards {
		cards[i] = c.String()
	}
	return HandEvalResponse{
		RankName:  eval.Rank.String(),
		Rank:      int(eval.Rank),
		BestCards: cards,
	}
}

func bestHandHandler(w http.ResponseWriter, r *http.Request) {
	enableCORS(w)
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	var req BestHandRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if len(req.Hole) != 2 || len(req.Community) != 5 {
		http.Error(w, "BestHand requires exactly 7 cards", http.StatusBadRequest)
		return
	}

	holeCards, err := poker.ParseCards(req.Hole)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}
	commCards, err := poker.ParseCards(req.Community)
	if err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	allCards := append([]poker.Card(nil), holeCards...)
	allCards = append(allCards, commCards...)

	seen := make(map[string]bool)
	for _, c := range allCards {
		if seen[c.String()] {
			http.Error(w, "duplicate card error", http.StatusBadRequest)
			return
		}
		seen[c.String()] = true
	}

	eval := poker.Evaluate7(allCards)
	resp := mapEvalResponse(eval)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func compareHandler(w http.ResponseWriter, r *http.Request) {
	enableCORS(w)
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	var req CompareRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	if len(req.Player1.Hole) != 2 || len(req.Player1.Community) != 5 || len(req.Player2.Hole) != 2 || len(req.Player2.Community) != 5 {
		http.Error(w, "invalid number of cards for evaluation", http.StatusBadRequest)
		return
	}

	p1Hole, err1 := poker.ParseCards(req.Player1.Hole)
	p1Comm, err2 := poker.ParseCards(req.Player1.Community)
	p2Hole, err3 := poker.ParseCards(req.Player2.Hole)
	p2Comm, err4 := poker.ParseCards(req.Player2.Community)

	if err1 != nil || err2 != nil || err3 != nil || err4 != nil {
		http.Error(w, "invalid card format", http.StatusBadRequest)
		return
	}

	checkDupes := func(cards []poker.Card) bool {
		seen := make(map[string]bool)
		for _, c := range cards {
			if seen[c.String()] {
				return false
			}
			seen[c.String()] = true
		}
		return true
	}

	p1Cards := append([]poker.Card(nil), p1Hole...)
	p1Cards = append(p1Cards, p1Comm...)
	if !checkDupes(p1Cards) {
		http.Error(w, "duplicate card error in player 1", http.StatusBadRequest)
		return
	}

	p2Cards := append([]poker.Card(nil), p2Hole...)
	p2Cards = append(p2Cards, p2Comm...)
	if !checkDupes(p2Cards) {
		http.Error(w, "duplicate card error in player 2", http.StatusBadRequest)
		return
	}

	p1Eval := poker.Evaluate7(p1Cards)
	p2Eval := poker.Evaluate7(p2Cards)

	winner := 0
	if p1Eval.Score > p2Eval.Score {
		winner = 1
	} else if p2Eval.Score > p1Eval.Score {
		winner = 2
	}

	resp := CompareResponse{
		Winner:      winner,
		Player1Eval: mapEvalResponse(p1Eval),
		Player2Eval: mapEvalResponse(p2Eval),
	}

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(resp)
}

func probabilityHandler(w http.ResponseWriter, r *http.Request) {
	enableCORS(w)
	if r.Method == "OPTIONS" {
		w.WriteHeader(http.StatusOK)
		return
	}

	var req ProbRequest
	if err := json.NewDecoder(r.Body).Decode(&req); err != nil {
		http.Error(w, err.Error(), http.StatusBadRequest)
		return
	}

	lc := len(req.Community)
	if lc != 0 && lc != 3 && lc != 4 && lc != 5 {
		http.Error(w, "community must be 0,3,4,5", http.StatusBadRequest)
		return
	}

	if len(req.Hole) != 2 {
		http.Error(w, "must have exactly 2 hole cards", http.StatusBadRequest)
		return
	}

	hole, err1 := poker.ParseCards(req.Hole)
	comm, err2 := poker.ParseCards(req.Community)
	if err1 != nil || err2 != nil {
		http.Error(w, "invalid cards", http.StatusBadRequest)
		return
	}

	allCards := append(append([]poker.Card(nil), hole...), comm...)
	seen := make(map[string]bool)
	for _, c := range allCards {
		if seen[c.String()] {
			http.Error(w, "duplicate card error", http.StatusBadRequest)
			return
		}
		seen[c.String()] = true
	}

	sims := req.Simulations
	if sims <= 0 {
		sims = 10000
	}

	players := req.NumPlayers
	if players < 2 {
		players = 2
	}

	res := poker.Simulate(hole, comm, players, sims)

	w.Header().Set("Content-Type", "application/json")
	json.NewEncoder(w).Encode(res)
}

func healthHandler(w http.ResponseWriter, r *http.Request) {
	enableCORS(w)
	w.WriteHeader(http.StatusOK)
	w.Write([]byte(`{"status":"ok"}`))
}

func main() {
	http.HandleFunc("/hand/best", bestHandHandler)
	http.HandleFunc("/hand/compare", compareHandler)
	http.HandleFunc("/hand/probability", probabilityHandler)
	http.HandleFunc("/health", healthHandler)

	fmt.Println("Backend server listening on ...")
	log.Fatal(http.ListenAndServe(":8081", nil))
}
