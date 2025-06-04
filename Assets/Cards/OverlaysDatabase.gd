
# Info [Value, Displayname, Filename, Effect, Suitless, Skip, Reverse, Draw]
enum {Zero, One, Two, Three, Four, Five, Six, Seven, Eight, Nine, Skip, Reverse, Draw2, Draw4, Wildcard}

const DATA = {
	Zero :
		[0, "Zero", "zero", false, false, 0, false, 0],
	One :
		[1, "One", "one", false, false, 0, false, 0],
	Two :
		[2, "Two", "two", false, false, 0, false, 0],
	Three :
		[3, "Three", "three", false, false, 0, false, 0],
	Four :
		[4, "Four", "four", false, false, 0, false, 0],
	Five :
		[5, "Five", "five", false, false, 0, false, 0],
	Six :
		[6, "Six", "six", false, false, 0, false, 0],
	Seven :
		[7, "Seven", "seven", false, false, 0, false, 0],
	Eight :
		[8, "Eight", "eight", false, false, 0, false, 0],
	Nine :
		[9, "Nine", "nine", false, false, 0, false, 0],
	Skip :
		[10, "Skip", "skip", true, false, 1, false, 0],
	Reverse :
		[11, "Reverse", "reverse", true, false, 0, true, 0],
	Draw2 :
		[12, "Draw2", "plus2", true, false, 0, false, 2],
	Draw4 :
		[13, "Draw4", "plus4", true, true, 0, false, 4],
	Wildcard :
		[14, "Wildcard", "wild", true, true, 0, false, 0]
	}
