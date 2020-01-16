#  CatFacts

CatFacts is a one-screen app that displays a list of cat facts and provides the option to post your own.
Rather than fetching the entire database, students will display 25 facts in a list and implement pagination to expand the list as the user scrolls downward.
Users will also practice reading documentation to perform a POST request.

## Part Zero - Familiarity with the Documentation

* Find which endpoint to hit
* Look at a sample response (JSON)
* Based off the JSON, determine how to structure your model(s)

All facts in the app are retrieved from and posted to **http://catfact.info/**.

1. Visit the above URL and look at the documentation. You want to GET multiple facts and later, to POST one fact.
2. In postman, do a practice run of each of the endpoints you will be hitting. You should have success with both endpoints before attempting to replicate it in a project.

## Part One - Storyboard and Model

### Storyboard

* Go to `Main.storyboard` and replace the default scene with a `UITableViewController`
* Embed the scene in a navigation stack.
* Add a `UIBarButtonItem` to the navigation bar, which will be used to add facts via POST request.

### Model

* Create a new file named `CatFact.swift` and declare a new struct `CatFact` that conforms to `Codable`.

* Add properties to your struct based off of the JSON you will be receiving. `id: Int?` and `details: String`. CatFact.id has to be optional, because you won't be sending an id in POST requests.

* On the same file, declare a new struct `TopLevelGETObject: Decodable`. Model it after the JSON you received in postman.

* Declare a third struct, `TopLevelPOSTObject: Encodable`. Model it after the JSON you sent in postman.

## Part Two - CatFactController and Custom Error

### CatFactController - GET CatFacts

* Create a new Swift file and class named `CatFactController`.

> This class doesn't hold any CatFact objects, so you don't need a singleton.

* Create a `private static let` to hold your base URL which will be used in all HTTP requests.

* Declare a static function to fetch facts from the server. It will take in a page number and a completion block `(Result <CatFact, CatFactError>) -> Void`
```
static func fetchCatFacts(page: Int, completion: @escaping (Result <CatFact, CatFact>) -> Void) {
    // 1 - Prepare URL
    
    // 2 - Contact server
    
    // 3 - Handle errors from the server
    
    // 4 - Check for json data
    
    // 5 - Decode json into a CatFact
}
```
* The compiler will complain about the nonexistent error type. Create a new Swift file and enum named `CatFactError` that conforms to `LocalizedError`.

* In `fetchCatFacts(page:completion:)`, append path component/extension until you have the fullBaseURL for your endpoint.

* Initialize an instance of `URLComponents` with your completed base URL.

* Create a `URLQueryItem` for the `page` number passed into your function. Search the documentation to find the query item's name. 

* Add your query item to the components you created and then unwrap the final URL.

* Call `URLSession.shared.dataTask` and finish off the rest of your CatFacts fetch. Remember to handle errors properly, adding new cases to your enum as needed.

### CatFactController - POST CatFact

* Declare a static function that takes in a string and completion block of type `(Result <CatFact, CatFactError>) -> Void`.
```
static func postCatFact(details: String, completion: @escaping (Result <CatFact, CatFactError>) -> Void) {

    // 1 - Prepare URL
    
    // 2 - Encode JSON
    
    // 3 - Create request
    
    // 4 - Contact server
    
    // 5 - Handle errors from the server
    
    // 6 - Check for/decode data
}
```

* Just as before, unwrap and assemble the full base URL.

* Declare a `URLRequest` from the url and change the `httpMethod` to `"POST"`.

* In the request header, set the content type to "Application/json". `request.setValue("Application/json", forHTTPHeaderField: "Content-Type")`

* Create a `CatFact` and `TopLevelPOSTObject` to be encoded.

* In a `do-catch` block, use `JSONEncoder` to turn your object into `Data`. Assign this data as the requests's `httpBody`.

* Call `URLSession.shared.dataTask` and finish off the rest of your CatFact post. Remember to handle errors properly, adding new cases to your enum as needed.

## Part Three - Custom Error Alert and CatFactTableViewController

### Custom Error Alert

* Create a new Swift file called `UIViewControllerExtension`.

* Import `UIKit` and extend `UIViewController`.

* Create a function that takes in a `LocalizedError` and presents a `UIAlertController` with the error's `errorDescription`.

```
extension UIViewController {
    
    func presentErrorToUser(localizedError: LocalizedError) {
        
        // Feel free to customize the alert controller.
        let alertController = UIAlertController(title: "Error", message: localizedError.errorDescription, preferredStyle: .actionSheet)
        let dismissAction = UIAlertAction(title: "Ok", style: .cancel)
        alertController.addAction(dismissAction)
        present(alertController, animated: true)
    }
}
```

* Because this function exists on the `UIViewController` class itself, you will be able to call it from any view controller in an app. Consider saving your extension as a code snippet for quick access in future projects.

### Fetch Facts

* Create a new Cocoa Touch class called `CatFactTableViewController` and subclass the view controller on your storyboard.

* Drag out an action for the add button.

* Create an empty array of CatFact that will be used as the data source for both required tableView methods. Add a property observer that automatically reloads the tableView.

* Write out a `fetchFacts` function that calls `CatFactController.fetchCatFacts(page:completion:)`. For now, set the page to 1.
Remember to handle both result cases. Because you will implement pagination later on, it's important to append, not replace facts.
```
case .success(let facts):
    self?.facts += facts
                   
case .failure(let error):
    self?.presentErrorToUser(localizedError: error)
```

* Call `fetchFacts` in `viewDidLoad` and run the simulator. You should be seeing a list of facts.
*If you are not succeeding, add the following to Info.plist*
*App Transport Security Settings > Allow Arbitrary Loads: YES*

### Post Fact

* Create a new method, `presentPostAlert` which presents a `UIAlertController` whenever the user presses the add button.

* Add a textField and two actions to the alert controller. One of the actions should simply dismiss the alert. The other will read text from the textField, and if it's not empty, call `CatFactController.postCatFact`.

*After a successful post, the server returns a CatFact as confirmation. You may simply print the fact to verify that it posted. Otherwise, feel free to add it to your data source array.*

* Call `presentPostAlert` from within the action you dragged out earlier and run the simulator. You should be successfully posting a new fact.

### Pagination

*In a database with potentially thousands of facts, it's impractical to request all of them at once. Pagination is a strategy to request only what is likely to be used, a little at a time.*

* Declare an integer `private var currentPage = 0`.

* In `fetchFacts`, increment `currentPage` by 1 before performing the fetch. Make sure that you pass it to your fetch function.

*Even though fetchFacts is incrementing the page number, it is still only being called once - in viewDidLoad. We need to determine an appropriate time to request more facts. Often, this is done when the user scrolls to the final cell.*

* In `cellForRowAt`, if `indexPath.row == facts.count - 1`, call `fetchFacts`.

* Run the simulator and the project is now complete.