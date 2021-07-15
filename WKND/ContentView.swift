//
//  ContentView.swift
//  fsiapp
//
//  Created by Mark Szulc on 25/2/21.
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        ZStack {
          Color("WKND_yellow")
          .edgesIgnoringSafeArea(.all)
        
            VStack(alignment: .leading, spacing: 0, content: {
                
                Image("WKND_logo")
                    .resizable()
                    .frame(width: 100, height: 40)
                    .padding(.top, 30)
                    .padding(.bottom, 10)
                
                
                adventureList()
               // offerlist()
                
                Spacer()

            }).padding(.horizontal, 0)
            .padding(.leading, 20)
        }.accentColor(Color.white)
    }
}
        

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
