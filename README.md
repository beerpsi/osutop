# osutop-repeats
Count how many repeats you have in your osu! top play. Now you can shame all the osu! players for having 11 padorus in their top play.

# osutop-sort
The new version, which now sorts by weighted pp. osutop-repeats will still be updated to have the same features as osutop-sort, except that osutop-repeats still count repeats.

# Usage
    ./osutop-sort.sh -h

If USERNAME has spaces, replace them with underscores (\_). For example, Maxim Bogdan becomes Maxim_Bogdan.

    
# Dependencies:
    jq 
    getops
    curl
    printf
    sort
    read
    echo
    if, elif, else, then, fi
# Problems:

Suppress jq error messages (if you see 
    
    jq: error (at <stdin>:0): Cannot index array with string "error"
    
it means that the API is valid.)

# TODOs:

- [x] Add sorting by total weighted pp gained from a song

- [ ] Support for private servers

- [ ] A LOT more error checking (invalid gamemode values, invalid username, etc.)

# Credits:
IOException for helping me early on

![IOException help](https://i.imgur.com/EGuPpMa.png)
# Why 11 padorus?
    
    ./osutop-repeats.sh -k <censored_api_key> -u Maxim_Bogdan 
      11 PADORU / PADORU
      4 Harumachi Clover (Swing Arrangement)
      4 Gokujo. no Jouken (TV Size)
      3 JUSTadICE (TV Size)
      3 Chikatto Chika Chika (TV Size)
      2 Yuima-ru*World TVver.
      2 V (TV Size)
      2 Take me to the top
      2 Start Again
      2 Snow Halation (feat. BeasttrollMC)
      2 Last Goodbye
      2 Guinea Pig Bridge
      2 Guess Who Is Back (TV Size)
      2 Granat
      2 Chikatto Chika Chika
      2 Black Rover (TV Size)
      1 Zen Zen Zense (movie ver.)
      1 Yubi Bouenkyou ~Anime-ban~
      1 You Suck At Love (Speed Up Ver.)
      1 Whereabouts Unknown
      1 Watashi, Idol Sengen
      1 Walk This Way!
      1 Totsugeki Rock
      1 Time Trials
      1 Teopacito feat. Will Stetson
      1 TEEN TITANS THEME (TV Size)
      1 Team Magma & Aqua Leader Battle Theme (Unofficial)
      1 Take a Hint feat. Victoria Justice & Elizabeth Gillies (Speed Up Ver.)
      1 Taisetsu no Tsukurikata (Asterisk Remix)
      1 SHIORI -TV size mix-
      1 Shinzou o Sasageyo! [TV Size]
      1 Sentou! Champion
      1 Sakura no Uta
      1 ROCK-mode
      1 quaver
      1 PUNCH LINE!
      1 POP/STARS
      1 Mr.Downer
      1 Monochrome Butterfly
      1 Mizuoto to Curtain
      1 MIIRO vs. Ai no Scenario
      1 Marshmary
      1 Make a Move (Speed Up Ver.)
      1 Love Synchronicity
      1 Lonely Go! (TV Size)
      1 Kuchizuke Diamond
      1 Koko wa Doko (TV Size)
      1 kibo refrain
      1 Kani*Do-Luck! (TV Size)
      1 I'll Be There For You (TV Version)
      1 humanly
      1 Hero
      1 Heart Goes Boom!! [GAME Mix]
      1 Haru Urara, Kimi to Sakihokoru (TV Size)
      1 Gold Dust
      1 FriendZoned
      1 Endless Starlight ~Inochi no Kirameki~ (OP ver.)
      1 CHEER UP
      1 Bye Bye YESTERDAY
      1 Blade Dance
      1 Beat Syncer
      1 Bass Slut (Original Mix)
      1 A New Journey (feat. AmaLee)
      1 Ame to Asphalt
      1 All I Know
      1 Ai no Sukima
      1 Ai no Scenario
      1 Acchu~ma Seishun!
      1 AaAaAaAAaAaAAa


