import Foundation
// Heavy client
/*
 All of the logic is client-side
 e.g. client makes all of the requests to HN API to get new stories and notify user, etc
 Good: easy, no server
 Bad: resource intensive (lots of requests from a battery-strapped client) -- not mobile-friendly design
 */

// Heavy server // light client -- winner in the long-run
/*
 Most of the logic is server-side -- server does the heavy lifting
 Client just registers w/ server, configures remote profile, and receives notifications
 Good: save resources client-side (i.e. battery life), implementation is more client-agnostic (using generic interface)
 Bad: you have server (one more thing, centralized, $) and need a registration mechanism
 */

// Get item IDs for top stories.
// Get item by item ID.
// Notify.

//var arr: [String] = ["a", "b"]
//var aoo: Array<String> = ["a", "b"]
//print(arr, aoo)

// let -- CONSTANTS!! immutable
// var -- NOT CONSTANTS!! mutable

struct HNItem {
    let ID:    Int
    let Score: Int
    let Time:  Int
    let Title: String
}

func getTopStories() -> [String] {
    return ["1", "2", "3", ""]
}

func getItem(itemID: Int) -> HNItem? {
    switch itemID {
    case 1:
        return HNItem(
            ID: itemID,
            Score: 10,
            Time: 0,
            Title: "Item numba 1!"
        )
    case 2:
        return HNItem(
            ID: itemID,
            Score: 101,
            Time: 0,
            Title: "Item numba 2!"
        )
    case 3:
        return HNItem(
            ID: itemID,
            Score: 110,
            Time: 0,
            Title: "Item numba 3!"
        )
    default:
        return nil
    }
}

let dayInSeconds = 24 * 60 * 60
let hourInSeconds = 60 * 60

struct UserConfig {
    let ScoreThreshold:         Int
    let MaxAge:                 Int // In hours. FIXME: Should be a time duration/interval.
    // MaxCacheAge is the amount of time an item stays in the cache.
    // Once the item is in the cache, and it's older than this value, it's removed from the cache.
    // The implication
    let MaxCacheAge:            Int // In hours. FIXME: Should be a time duration/interval.
    let CacheDeleteFrequency:   Int // In hours.
    let NewStoryCheckFrequency: Int // In hours.
    
    init(scoreThreshold:         Int = 100,
         maxAge:                 Int = 2 * dayInSeconds,
         maxCacheAge:            Int = 2 * dayInSeconds,
         cacheDeleteFrequency:   Int = 12 * hourInSeconds,
         newStoryCheckFrequency: Int = 4 * hourInSeconds
         ) {
        self.ScoreThreshold = scoreThreshold
        self.MaxAge = maxAge
        self.MaxCacheAge = maxCacheAge
        self.CacheDeleteFrequency = cacheDeleteFrequency
        self.NewStoryCheckFrequency = newStoryCheckFrequency
    }
}

var itemIDs = getTopStories()
var config = UserConfig()
var now = Date().timeIntervalSince1970
print(now, now - Double(2 * dayInSeconds))
print(
    Date(timeIntervalSince1970: now), "\n",
    Date(timeIntervalSince1970: now - Double(2 * dayInSeconds))
)

for id in itemIDs {
    if let iid = Int(id), let item = getItem(itemID: iid) {
        if item.Score > config.ScoreThreshold {
            print("You have mail!", item)
        }
    }
}

/*
 
 */
