//
//  offerlist.swift
//  foo
//
//  Created by Mark Szulc on 21/2/21.
//

import SwiftUI

struct adventureList: View {
    
    @ObservedObject var fetcher = AEM_adventureListFetcher()
        
    var body: some View {
        
        VStack (alignment: .leading, spacing: 0) {

                 Text("Our Adventures")
                    .foregroundColor(Color.black)
                    .font(.custom("Asar-Regular", size: 36))
                           .bold()
                    .padding(.all, 0)

                 ScrollView(.horizontal, showsIndicators: false) {
                     HStack (alignment: .top, spacing: 10) {
                         ForEach(fetcher.adventureListheadless, id: \.adventureTitle) { adventure in
                             
                                     VStack (alignment: .leading, spacing: 5) {
        
                                        let url = URL(string: "https://publish-p24704-e76433.adobeaemcloud.com" + adventure.adventurePrimaryImage._path)!
                                        
                                        AsyncImage(
                                            url: url,
                                           placeholder: { Text("Loading ...") },
                                           image: { Image(uiImage: $0)
                                                .resizable()
                                           }
                                        ).frame(height: 160)

                                        
                                         Text(adventure.adventureTitle)
                                            .font(.custom("SourceSansPro-Bold", size: 24))
                                          .foregroundColor(Color.black)
                                          .bold()
                                          .padding(0)
                                          .padding(.leading, 10)

                                        Text("from " + adventure.adventurePrice)
                                          .font(.custom("SourceSansPro-Regular", size: 18))
                                            .foregroundColor(Color.black)
                                            .padding(.all, 0)
                                            .padding(.leading, 10)

                                        Spacer()

                                     }
                                     .frame(width: 250, height: 230)
                                     .background(Color.white)
                                    
                                 }
                         }
                         .frame(height: 250)
                     .padding(.all, 0.0)
                 }
                 .padding(.all, 0.0)
        }.foregroundColor(.white)
    }

}

struct adventureList_Previews: PreviewProvider {
    static var previews: some View {
        ZStack {
          Color("WKND_yellow")
          .edgesIgnoringSafeArea(.all)
        
            VStack(alignment: .leading, spacing: 30, content: {
                adventureList()
            }).padding(.horizontal, 0)
            .padding(.leading, 20)
            
            }
    }
}


public class AEM_adventureListFetcher: ObservableObject {
    @Published var adventureListheadless = [Adventure.Data.AdventureList.Items]()
    
    init(){
        load()
    }
    
    func load() {
            
        let semaphore = DispatchSemaphore (value: 0)
        
        let parameters = "{\"query\":\"{ adventureList {\\n items {\\n _path\\n adventureTitle\\n adventurePrice\\n adventureTripLength\\n adventurePrimaryImage {\\n ... on ImageRef {\\n _path\\n _publishUrl\\n mimeType\\n width\\n height\\n }\\n }\\n }\\n }\\n }\\n\",\"variables\":{}}"
        
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
                let adventureJSON = try JSONDecoder().decode(Adventure.self, from: data)
                let offerCount = adventureJSON.data.adventureList.items.count
                            print(offerCount)
                           
                            DispatchQueue.main.async {
                                self.adventureListheadless = adventureJSON.data.adventureList.items
                                dump(self.adventureListheadless)
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


struct Adventure: Codable {
    struct Data : Codable {
        struct AdventureList : Codable {
                struct Items : Codable {
                    let _path : String
                    let adventureTitle : String
                    let adventurePrice : String
                    let adventureTripLength : String
                    struct PrimaryImage : Codable {
                        let _path: String
                        let _publishUrl: String
                        let mimeType: String
                        let width: Int
                        let height: Int
                    }
                    let adventurePrimaryImage:PrimaryImage
                }
            let items:[Items]
        }
        let adventureList:AdventureList

    }
     let data:Data
}


