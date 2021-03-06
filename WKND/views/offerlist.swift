//
//  offerlist.swift
//  foo
//
//  Created by Mark Szulc on 21/2/21.
//

import SwiftUI

struct offerlist: View {
    
    @ObservedObject var fetcher = AEM_offerFetcher()
        
    var body: some View {
        
        VStack (alignment: .leading, spacing: 1) {

                 Text("Our Offers")
                    .foregroundColor(Color.black)
                    .font(.custom("Asar-Regular", size: 36))
                           .bold()

                 ScrollView(.horizontal, showsIndicators: false) {
                     HStack (alignment: .top, spacing: 20) {
                         ForEach(fetcher.offerlistheadless, id: \.headline) { offer in
                             
                                     VStack (alignment: .leading, spacing: 5) {
        
         //                               let url = URL(string: "https://publish-p24704-e76433.adobeaemcloud.com" + offer.adventurePrimaryImage._path)!
                                        
//                                        AsyncImage(
//                                            url: url,
//                                           placeholder: { Text("Loading ...") },
//                                           image: { Image(uiImage: $0)
//                                                .resizable()
//                                           }
//                                        ).frame(height: 160)

                                        
                                         Text(offer.headline)
                                            .font(.custom("SourceSansPro-Bold", size: 24))
                                          .foregroundColor(Color.black)
                                          .bold()
                                            .padding(0)
                                            .padding(.leading, 10)

//                                        Text("from " + offer.adventurePrice)
//                                          .font(.custom("SourceSansPro-Regular", size: 18))
//                                            .foregroundColor(Color.black)
//                                            .padding(0)
//                                            .padding(.leading, 10)

                                        Spacer()

                                     }
                                     .frame(width: 250, height: 230)
                                     .background(Color.white)
                                     .border(Color("WKND_yellow"))
                                    
                                 }
                         }
                         .frame(height: 250)
                     }
             }.foregroundColor(.white)
    }
}

struct offerlist_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
          Color("WKND_yellow")
          .edgesIgnoringSafeArea(.all)
        
            VStack(alignment: .leading, spacing: 30, content: {
                offerlist()
            }).padding(.horizontal, 0)
            .padding(.leading, 20)
            
            }
    }
}


public class AEM_offerFetcher: ObservableObject {
    @Published var offerlistheadless = [Offer.Data.OfferList.Items]()
    
    init(){
        load()
    }
    
    func load() {
            
        let semaphore = DispatchSemaphore (value: 0)
        
        let parameters = "{\"query\":\"{\\n  offerList {\\n    items {\\n      headline\\n      detail {\\n        plaintext\\n      }\\n      heroImage {\\n        ... on ImageRef {\\n          _path\\n        }\\n      }\\n    }\\n  }\\n}\\n\",\"variables\":{}}"
        
        
        let postData = parameters.data(using: .utf8)

        let url = URL(string: "https://publish-p24704-e76433.adobeaemcloud.com/content/_cq_graphql/global/endpoint.json")!

        var request = URLRequest(url: url)
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        request.httpMethod = "POST"
        request.httpBody = postData
    
        let task = URLSession.shared.dataTask(with: request) { data, response, error in
          guard let data = data else {
            //print(String(describing: error))
            semaphore.signal()
            return
          }
          print(String(data: data, encoding: .utf8)!)
            do {
                let offerJSON = try JSONDecoder().decode(Offer.self, from: data)
                let offerCount = offerJSON.data.offerList.items.count
                            print(offerCount)
                           
                            DispatchQueue.main.async {
                                self.offerlistheadless = offerJSON.data.offerList.items
                                dump(self.offerlistheadless)
                            }
                            
                            
                            } catch let jsonErr {
                                            print(".................................")
                                            print("Error serializing json:", jsonErr)
                            }
        
          semaphore.signal()
        }

        task.resume()
        semaphore.wait()
        
    }
}


struct Offer: Codable {
    struct Data : Codable {
        struct OfferList : Codable {
                struct Items : Codable {
                    let headline : String
                }
            let items:[Items]
        }
        let offerList:OfferList

    }
     let data:Data
}


