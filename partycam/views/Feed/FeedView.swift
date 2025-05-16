//
//  FeedView.swift
//  partycam
//
//  Created by Joey Lyon on 5/16/25.
//

import Foundation
import SwiftUI

struct Feed: Identifiable {
    var id = UUID()
    
    //User
    var profileImage: String
    var username: String
    
    //Context
    var text: String
    var likes: Int
    var comments: Int
    
    var images: [String]
}

struct FeedPost: View {
    @State var feed: Feed
    @State var currentCarouselIndex = 0
    
    var body: some View {
        VStack {
            header
            carousel
            buttons
            textView
        }
        .frame(maxWidth: .infinity)
        .frame(height: 500)
        .padding(.bottom)
    }
    
    var header: some View {
        HStack {
            Text(String(feed.username.prefix(1)))
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(width: 35, height: 35)
                .background(Circle().fill(Color.blue))
            
            Text(feed.username)
                .font(.system(size: 16, weight: .semibold))
            
            Spacer()
            
            Button {
                // Action
            } label: {
                Image(systemName: "ellipsis")
            }
        }
        .padding(.horizontal)
    }
    
    var carousel: some View {
        TabView(selection: $currentCarouselIndex) {
            ForEach(0..<feed.images.count, id: \.self) { index in
                Image(feed.images[index])
                    .resizable()
                    .scaledToFill()
                    .tag(index)
            }
        }
        .overlay(alignment: .bottom) {
            carouselIndicators
                .offset(CGSize(width: 0, height: 30))
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .never))
    }
    
    var carouselIndicators: some View {
        HStack {
            ForEach(0..<feed.images.count, id: \.self) { index in
                Circle()
                    .fill(index == currentCarouselIndex ? .blue : Color(red: 0.8, green: 0.8, blue: 0.8))
                    .frame(width: 6, height: 6)
            }
        }
    }
    
    var buttons: some View {
        HStack {
            //Like Button
            Button {
                
            } label: {
                Image(systemName: "heart")
            }
            
            //Comment Button
            Button {
                
            } label: {
                Image(systemName: "message")
            }
            
            //Share Button
            Button {
                
            } label: {
                Image(systemName: "paperplane")
            }
            
            Spacer()
            //Save Button
            Button {
                
            } label: {
                Image(systemName: "bookmark")
            }
        }
        .font(.system(size: 22))
        .padding(.horizontal)
        .padding(.vertical, 6)
    }
    
    var textView: some View {
        VStack(alignment: .leading, spacing: 6) {
            HStack {
                //Profileimage of a person that have liked the post
                Image("Others Profile Image")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 15, height: 15)
                    .clipShape(Circle())
                
                //Text that says how many people have liked
                Text("Liked by **\(feed.likes)** others")
                    .font(.system(size: 12))
                
                Spacer()
            }
            
            //Main Text
            Text("**\(feed.username)** \(feed.text)")
                .font(.system(size: 14))
                .multilineTextAlignment(.leading)
            
            //Comment Text
            Button {
                //Show Comments
            } label: {
                Text("Show all \(feed.comments) comments")
                    .font(.system(size: 12, weight: .thin))
            }

            //Timestamp Text
            Text("14 hours ago")
                .font(.system(size: 10, weight: .thin))
        }
        .padding(.horizontal)
    }
}

struct FeedView: View {

  var body: some View {
      ScrollView {
          VStack {
              feed
          }
      }
  }

  var feed: some View {
      ForEach(1..<10) { _ in
         FeedPost(feed: Feed(
          profileImage: "Profile Image",
          username: "Unknown User",
          text: "Embracing the green vibes as I effortlessly mow the grass, creating picture-perfect lines that transform my lawn into a work of art. 🌿✨ #LawnLove #GrassGoals",
          likes: 43,
          comments: 2,
          images: ["Placeholder Image", "Placeholder Image", "Placeholder Image"]
         )
         )
      }
  }
}
