// NewsDownloadManager.swift

import Foundation

final class NewsDownloadManager: ObservableObject {
    @Published var newsArticles = [News]()

    private let newsUrlString = "https://newsapi.org/v2/top-headlines?country=us&category=business&apiKey=\(NewsAPI.key)"

    init() {
        download()
    }

    func download() {
//        NetworkManager<NewsResponse>().fetch(from: URL(string: newsUrlString)!) { (result) in
//            switch result {
//            case .failure(let err):
//                print(err)
//            case .success(let resp):
//                DispatchQueue.main.async {
//                    self.newsArticles = resp.articles
//                }
//            }
//        }
        // zscaler seems to be causing some sort of connection error so just load in a
        // couple dummy articles like we did for mock quotes
        let NBC = News(title: "NBC News", url: "https://nbcnews.com", urlToImage: nil)
        let FOX = News(title: "Fox News", url: "https://foxnews.com", urlToImage: nil)
        for _ in 0..<4 {
            newsArticles.append(contentsOf: [NBC, FOX])
        }
    }
}
