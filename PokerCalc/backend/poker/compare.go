package poker

type CompareResult struct {
	Winner      int      `json:"winner"`
	Player1Eval HandEval `json:"player1_eval"`
	Player2Eval HandEval `json:"player2_eval"`
}

func CompareHands(p1Hole, p2Hole, community []Card) CompareResult {
	c1 := append([]Card(nil), p1Hole...)
	c1 = append(c1, community...)
	e1 := Evaluate7(c1)

	c2 := append([]Card(nil), p2Hole...)
	c2 = append(c2, community...)
	e2 := Evaluate7(c2)

	winner := 0
	if e1.Score > e2.Score {
		winner = 1
	} else if e2.Score > e1.Score {
		winner = 2
	}

	return CompareResult{
		Winner:      winner,
		Player1Eval: e1,
		Player2Eval: e2,
	}
}
