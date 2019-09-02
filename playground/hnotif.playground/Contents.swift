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

let dayInSeconds = 24 * 60 * 60,
    hourInSeconds = 60 * 60

// UserConfig is the configuration
struct AppConfig {
    var ScoreThreshold:         Int
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

// HNDB is a mock DB.
class HNDB {
    // Item is a DB model for a HN Item.
    struct Item {
        let ID:    String
        let HNID:  Int
        let Score: Int
        let Time:  Int
        let Title: String
        
        init(hnItem: HNController.HNItem) {
            self.ID = UUID().uuidString
            self.HNID = hnItem.ID
            self.Score = hnItem.Score
            self.Time = hnItem.Time
            self.Title = hnItem.Title
        }
    }
    
    // "Tables".
    var stories: [Int: Item] // stories table mock.
    
    init() {
        self.stories =  [Int: Item]()
    }

    // TODO: Should this return/throw an err?
    func createItem(_ item: Item) {
        self.stories[item.HNID] = item
    }

    func getItem(_ id: Int) -> Item? {
        return self.stories[id]
    }

    func deleteItem(_ item: Item) {
        let _ = self.stories.removeValue(forKey: item.HNID)
    }
}

// HNController ...
class HNController {
    struct HNItem {
        let ID:    Int
        var Score: Int
        var Time:  Int
        let Title: String
    }
    
    struct CachedStory {
        let Time: Int
    }
    
    var config: AppConfig
    
    init() {
        self.config = AppConfig()
    }

    // getTopStories returns top 500 story IDs.
    // TODO: This is mocked. Implement actual HTTP call.
    func getTopStories() -> [Int] {
        return [1, 2, 3]
    }
    
    // getItem returns an HNItem for the given item ID.
    // TODO: This is mocked. Implement actual HTTP call.
    func getItem(_ itemID: Int) -> HNItem? {
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
    
    // checkStories returns a list of stories that meet the config and the user has not seen before.
    func getNewStories(_ db: HNDB) -> [HNItem] {
        // Get the top stories
        let itemIDs = getTopStories()
        var newStories = [HNItem]()
        
        for id in itemIDs {
            // If the item has been stored, we don't want to check for it.
            if let item = db.getItem(id) {
                continue
            }

            if let item = getItem(id) {
                if item.Score > self.config.ScoreThreshold {
                    newStories.append(item)
                    db.createItem(HNDB.Item(hnItem: item))
                }
                if item.Time > 2 * dayInSeconds {
                    db.createItem(HNDB.Item(hnItem: item))
                }
            }
        }
        
        return newStories
    }
}

func main() {
    let c = HNController()
    let db = HNDB()

    // Get new stories and notify user.
    var stories = c.getNewStories(db)
}
main()


class TestHNController: HNController {
    var hnItem1 = HNItem(
            ID: 1,
            Score: 10,
            Time: 0,
            Title: "Item numba 1!"
    ), hnItem2 = HNItem(
            ID: 2,
            Score: 101,
            Time: 0,
            Title: "Item numba 2!"
    ), hnItem3 = HNItem(
            ID: 3,
            Score: 110,
            Time: 0,
            Title: "Item numba 3!"
    )

    override func getTopStories() -> [Int] {
        return [1, 2, 3]
    }

    override func getItem(_ itemID: Int) -> HNItem? {
        switch itemID {
        case 1:
            return hnItem1
        case 2:
            return hnItem2
        case 3:
            return hnItem3
        default:
            return nil
        }
    }
}

/*
 *
 ** Testing. **
 *
 */

// expect returns true if the actual matches expected.
func expect(_ expected: Any, _ actual: Any) -> Bool {
    let eType = type(of: expected)
    let aType = type(of: actual)
    if eType != aType {
        print("Incomparible types.")
        return false
    }
    if let e = expected as? Int, let a = actual as? Int {
        return e == a
    }
    if let e = expected as? String, let a = actual as? String {
        return e == a
    }
    return false
}

func mustExpect(_ expected: Any, _ actual: Any) {
    if !expect(expected, actual) {
        print("Unexpected values:\n\tExpected: \(expected)\n\tActual:   \(actual)")
        exit(1)
    }
}

func TestApp() {
    let c = TestHNController()
    let db = HNDB()
    c.config.ScoreThreshold = 100

    struct Test {
        let Title: String
        let TestFunc: () -> ()
    }
    
    // Goal: Ensure if a story has been seen before, it is not returned in the second call to getNewStories().
    func TestSeenStories() {
        var stories = c.getNewStories(db)
        mustExpect(2, stories.count)
        stories = c.getNewStories(db)
        mustExpect(0, stories.count)
        
        db.deleteItem(HNDB.Item(hnItem: c.hnItem1))
        db.deleteItem(HNDB.Item(hnItem: c.hnItem2))
        db.deleteItem(HNDB.Item(hnItem: c.hnItem3))
    }

    // Goal: Ensure stories older than 2 days are not return from a call to getNewStories().
    func TestOldStories() {
        // Set the time of item 1 to now + 2 days in the future.
        c.hnItem1.Time = Int(Date().timeIntervalSince1970) - c.config.MaxAge - 1
        c.hnItem1.Score = c.config.ScoreThreshold + 1 // Ensure item gets recognized for score.
        c.hnItem2.Score = c.config.ScoreThreshold - 1
        c.hnItem3.Score = c.config.ScoreThreshold - 1

        var stories = c.getNewStories(db)
        mustExpect(1, stories.count)
        stories = c.getNewStories(db)
        mustExpect(0, stories.count)

        db.deleteItem(HNDB.Item(hnItem: c.hnItem1))
        db.deleteItem(HNDB.Item(hnItem: c.hnItem2))
        db.deleteItem(HNDB.Item(hnItem: c.hnItem3))
    }

    var tests: [Test] = [
        Test(Title: "Test Seen Stories", TestFunc: TestSeenStories),
        Test(Title: "Test Old Stories", TestFunc: TestOldStories)
    ]
    for test in tests {
        print("Running Test: \(test.Title)... ", terminator: "")
        test.TestFunc()
        print("Test finished.")
    }
}
TestApp()

/*
 // Add an item to the DB, for it to not come back as a new story.
 db.createItem(HNDB.Item(hnItem: c.hnItem2))
*/
