# Movies - Assignment
Movies application in an iOS app that displays a listing of movies produced in year 2017 and 2018. 

## Features 
- Home screen of the application by default loads 2017 and 2018 movies matching "Batman" search keyword.
- Home screen shows a search text box to enter search term or keyword to search in the title of the movies. Search text box appears by swipe down gesture on the home screen. Minimum 2 characters should be entered to search. 
- Home screen shows top 10 movies with highest rating. Movies are sorting for highest rating using the "vote average" field of the movies model data. 
- Application attributes TMDb as the source of data and images in the application information page. Information page appears from the info button on home screen. 
- Application needs TMDb API key to load movies data from TMDb. User must enter API key from the Configuration View. Configuration View appears from the settings button on the home screen. 
- Movies Details screen should more detailed movies information title, poster, vote count, vote average, overview, and release date.

## Development Approach 
- Source code of Movies application is divide in 3 projects/ layers/ modules- 
1. MoviesApp - iOS application or the User app or the UI 
2. MoviesKit - Objective-C base dynamic library. It contains the public APIs for downloading movies data from TMDb based on the given search string
3. SortMovies - Pure C code based static library. It sorts the movies list based on the highest rating, using the "vote average" field of the movies model. It is used by the MoviesKit dynamic library. 
- Only used iOS Foundation and Core Foundation frameworks. Also, no third party frameworks or libraries are used. Not even for Unit Test. Have not even used OCMock for unit tests, since it was asked not to use any third party frameworks. 
- Create a full suite of unit tests for testing MoviesKit (dynamic library) and SortMovies (static library). Code coverage is around 97.5%. 
- Application treats API key as a secret, hence app has following security implementation for API key -
-- It saves it in the local storage in encrypted form. For this application has implemented custom crypto algorithm. 
-- It does not reads or allows user to enter API key, on Jailbroken iOS devices. 

## Visual Window
![MoviesApp](video/movies_app_flow.gif "Movies App Flow")

## Getting Started
The only Prerequisites for the project is [Xcode](https://developer.apple.com/xcode/). Once you have XCode follow these steps. 
### 1. Clone and Open
```bash
# Clone the repo
git clone https://github.com/1986ajitsingh/MoviesKit.git

# Goto to MoviesApp project folder
cd MoviesApp

# Open project in XCode
```

# Running the tests
Both libraries in the source code, that is, MoviesKit - iOS Dynamic library and SortMovies - C static library, are packed with Unit Tests. Code coverage is 97.5%. 
### For running unit tests - 
- Select respective library project as target in XCode 
- Select Product and then Test option 
### To generate code coverage report 
- Select Edit Scheme from XCode 
- Select the respect target 
- Select Test, then Options tab and enable Code Coverage 
- Run unit test as mentioned above 



## Running on the Device
- Plug in your device via USB
- Configure code signing
- Build and Run the app

## Deployment on App Store/ Play Store
Following are the high-level steps required to deploy the app on Apple App Store, for details please refer Apple's official documentation. 
- Create App Store provisioning profile  
- Register app on iTunes Connect
- Create iTunes app content and screenshots
- Add app icons and launch image 
- Create app archive (IPA)
- Upload the app to App Store via XCode 
- Use Test Flight for Beta testing and Release

## Author
[**Ajit Singh**](https://www.linkedin.com/in/1986ajitsingh/
) - Poly-skilled Developer with hands-on expertise on the web and mobile platforms like iOS, React JS, React Native, and BREW, across domains like IoT, security, communication, and healthcare. Well-versed in programming languages like C, C++, Objective-C, Swift, and JavaScript. 

### Post by the author: 
-  [*Blog*](https://www.globallogic.com/blogs/author/ajit-singh/)
- *Whitepapers*
- [Mobile Application Architecture: React Native with Redux](https://www.globallogic.com/gl_news/mobile-application-architecture-react-native-with-redux/)
- [A Review of React Native for Cross-platform Mobile Application Development](https://www.globallogic.com/gl_news/a-review-of-react-native-for-cross-platform/)
- [Enabling Enterprise Collaboration Platforms with Mitel Embedded Communications (MiEC) SDK V6.0](https://www.globallogic.com/gl_news/enabling-enterprise-collaboration-platforms-with-mitel-embedded-communications-miec-sdk-v6-0/)
- [Cashless India: Leveraging Possibilities and Facing Security Challenges In the Mobile Space](https://www.globallogic.com/gl_news/cashless-india-leveraging-possibilities-and-facing-security-challenges-in-the-mobile-space/)
- [Smart Homes: A Deep Dive](https://www.globallogic.com/gl_news/smart-homes-a-deep-dive/)
