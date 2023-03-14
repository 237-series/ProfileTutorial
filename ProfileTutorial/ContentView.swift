//
//  ContentView.swift
//  ProfileTutorial
//
//  Created by sglee237 on 2023/03/14.
//

import SwiftUI

import PhotosUI
import CoreTransferable

struct ProfileRow: View {
    @State private var selectedImageItem: PhotosPickerItem?
    @State private var profileImage: Image?
    
    @State private var selectedImageList: [PhotosPickerItem]?
    
    func saveImgae(imageData:Data) {
        let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
        let url = documents.appendingPathComponent("profile.png")
        
        do {
            try imageData.write(to: url)
            UserDefaults.standard.set(url, forKey: "profile.png")
        } catch {
            
        }
        
    }
    
    func loadImage() {
        if profileImage == nil {
            if let url = UserDefaults.standard.url(forKey: "profile.png") {
                if let image = UIImage(contentsOfFile: url.path()) {
                    profileImage = Image(uiImage: image)
                }
            }
        }
    }
    
    var body: some View {
        ZStack {
            PhotosPicker("", selection: $selectedImageItem, matching: .images)
            VStack(alignment: .center) {
                if let profileImage {
                    profileImage
                        .resizable()
                        .frame(width: 100, height: 100)
                        .aspectRatio(contentMode: .fit)
                        .clipShape(Circle())
                }
                else {
                    Image(systemName: "person")
                        .resizable()
                        .frame(width: 60, height: 60)
                        .padding()
                        .background(Circle().strokeBorder())
                }
                Text("Profile Name")
                    .font(.title)
            }
        }
        .onAppear(perform: {
            loadImage()
        })
        .onChange(of: selectedImageItem) { newValue in
            Task {
                if let data = try? await selectedImageItem?.loadTransferable(type: Data.self) {
                    if let uiImage = UIImage(data: data) {
                        profileImage = Image(uiImage: uiImage)
                        if let imgdata = uiImage.pngData() {
                            saveImgae(imageData: imgdata)
                        }
                    }
                    return
                }
            }
        }
    
    }
}

struct ContentView: View {
    var body: some View {
        VStack {
            Form {
                Section {
                    ProfileRow()
                }
            }
        }
        .padding()
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
