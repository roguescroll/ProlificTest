# ProlificTest

This project allows to user to get a list of books, Add new books, View book details and checkout the book,share the book details using the inbuilt sharing, Delete a single book or Delete all books.

The BooksViewController is the controller which shows the list of all books. It has 2 navigation bar buttons - Add book and Clear Books. It also allows the user to be able to delete a single book from the list.

Tapping the Add book brings up the AddBookViewController. This allows the user to enter all the information and add the book. It also makes a check to ensure atleast the Title and the Author are filled up before adding a new book.

Tapping on a book will bring up the book details view. The user can checkout the book by tapping on the checkout button which brings up an alert asking the user to enter a Name. Once the user enters a name, the view will be refreshed showing who checked out the book and at what time. The user can also share the book details. This is done using the UIActivityViewController, which brings up all the sharing options that the user has setup on the device.

I used NSURLConnection and its delegate methods to make the necessary requests and handle both the success and error responses.
I have not used any external JSON parsing libraries but handled it by parsing manually.

I have used a external class - MBProgressHUD to show indicators when there is a service call in progress.

I have used 1 storyboard file to handle the BooksViewController and BookDetailsViewController. I have a seperate Xib file for the AddBookViewController. I have used autolayout to layout the UI Elements.
