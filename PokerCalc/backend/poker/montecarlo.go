package poker

import (
	"math/rand"
	"time"
)

type MonteCarloResult struct {
	WinProbability  float64 `json:"win_probability"`
	TieProbability  float64 `json:"tie_probability"`
	LossProbability float64 `json:"loss_probability"`
}

func Simulate(hole []Card, community []Card, numPlayers int, simulations int) MonteCarloResult {
	if numPlayers < 2 {
		return MonteCarloResult{WinProbability: 1.0}
	}

	exclude := append([]Card(nil), hole...)
	exclude = append(exclude, community...)
	deck := buildDeck(exclude)
	rng := rand.New(rand.NewSource(time.Now().UnixNano()))

	wins, ties, losses := 0, 0, 0
	neededComm := 5 - len(community)
	cardsNeeded := neededComm + (numPlayers-1)*2

	myCards := make([]Card, 7)
	copy(myCards, hole)
	copy(myCards[2:], community)

	oppCards := make([]Card, 7)
	copy(oppCards[2:], community)

	for i := 0; i < simulations; i++ {
		temp := make([]Card, len(deck))
		copy(temp, deck)

		// Shuffle needed cards
		for j := 0; j < cardsNeeded; j++ {
			idx := j + rng.Intn(len(temp)-j)
			temp[j], temp[idx] = temp[idx], temp[j]
		}

		cursor := 0
		for j := 0; j < neededComm; j++ {
			c := temp[cursor]
			myCards[2+len(community)+j] = c
			oppCards[2+len(community)+j] = c
			cursor++
		}

		myEval := Evaluate7(myCards)
		isTie := false
		isLoss := false

		for p := 1; p < numPlayers; p++ {
			oppCards[0] = temp[cursor]
			oppCards[1] = temp[cursor+1]
			cursor += 2

			oppEval := Evaluate7(oppCards)

			if oppEval.Score > myEval.Score {
				isLoss = true
				break
			} else if oppEval.Score == myEval.Score {
				isTie = true
			}
		}

		if isLoss {
			losses++
		} else if isTie {
			ties++
		} else {
			wins++
		}
	}

	total := float64(simulations)
	return MonteCarloResult{
		WinProbability:  float64(wins) / total,
		TieProbability:  float64(ties) / total,
		LossProbability: float64(losses) / total,
	}
}

func buildDeck(exclude []Card) []Card {
	var deck []Card
	suits := []byte{'H', 'S', 'C', 'D'}
	excludeMap := make(map[string]bool)
	for _, c := range exclude {
		excludeMap[c.String()] = true
	}

	for _, s := range suits {
		for r := 2; r <= 14; r++ {
			c := Card{Suit: s, Rank: r}
			if !excludeMap[c.String()] {
				deck = append(deck, c)
			}
		}
	}
	return deck
}
