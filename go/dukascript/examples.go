package dukascript

import (
	"context"
	"fmt"
	"log"
	"os"
	"time"
)

func examples() {
	func() {
		ctx := context.Background()

		start, _ := time.Parse(time.DateOnly, "2025-04-21")
		end := start.Add(time.Hour * 24)

		df := Fetch(ctx, FetchArgs{
			Instrument: INSTRUMENT_FX_MAJORS_AUD_USD,
			OfferSide:  OFFER_SIDE_BID,
			Start:      start,
			End:        end,
			MaxRetries: 2,
			Interval:   INTERVAL_TICK,
		})

		file, err := os.Create("out.csv")
		if err != nil {
			log.Fatal(err)
		}

		defer file.Close()
		err = df.ToCSV(file)

		if err != nil {
			log.Fatal(err)
		}
	}()

	//
	func() {
		ctx := context.Background()

		start, _ := time.Parse(time.DateOnly, "2025-04-21")
		end := start.Add(time.Hour * 24)

		dfChan := LiveFetch(ctx, LiveFetchArgs{
			Instrument:    INSTRUMENT_FX_MAJORS_AUD_USD,
			OfferSide:     OFFER_SIDE_BID,
			Start:         start,
			End:           end,
			MaxRetries:    2,
			IntervalValue: 1,
			TimeUnit:      TIME_UNIT_HOUR,
		})

		file, err := os.Create("out.json")
		if err != nil {
			fmt.Println(err)
			return
		}

		defer file.Close()
		var df Dataframe

		for df = range dfChan {
		}

		err = df.ToJSON(file)

		if err != nil {
			log.Fatal(err)
		}
	}()

	func() {
		ctx, cancel := context.WithTimeout(context.Background(), time.Second*10)
		defer cancel()

		start, _ := time.Parse(time.DateOnly, "2025-04-21")
		var end time.Time

		dfChan := LiveFetch(ctx, LiveFetchArgs{
			Instrument:    INSTRUMENT_FX_MAJORS_AUD_USD,
			OfferSide:     OFFER_SIDE_BID,
			Start:         start,
			End:           end,
			MaxRetries:    2,
			IntervalValue: 1,
			TimeUnit:      TIME_UNIT_HOUR,
		})

		file, err := os.Create("out2.json")
		if err != nil {
			fmt.Println(err)
			return
		}

		var df Dataframe

		defer file.Close()
		defer func() {
			err = df.ToJSON(file)

			if err != nil {
				log.Fatal(err)
			}
		}()

		for df = range dfChan {
		}

	}()
}
