//
//  ContentView.swift
//  VoiceNoteApp
//
//  Created by Deepak on 14/07/21.
//

import SwiftUI
import AVKit

struct ContentView: View {
    
    var body: some View {
        RecordView()
            .preferredColorScheme(.dark)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}

struct RecordView: View {
    
    @State var record: Bool = false
    @State var alert: Bool = false
    
    @State var session: AVAudioSession!
    @State var recorder: AVAudioRecorder!
    @State var recordings: [URL] = []
    
    var body: some View {
        NavigationView {
            VStack {
                
                List(self.recordings, id: \.self) { item in
                    
                    Text(item.relativeString)
                }
                
                Button(action: {
                    do {
                        if self.record {
                            self.recorder.stop()
                            self.record.toggle()
                            self.getRecordings()
                            return
                        }
                        let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
                        
                        let fileName = url.appendingPathComponent("recording\(self.recordings.count + 1).m4a")
                        
                        let settings = [
                            AVFormatIDKey: Int(kAudioFormatMPEG4AAC),
                            AVSampleRateKey: 12000,
                            AVNumberOfChannelsKey: 1,
                            AVEncoderAudioQualityKey: AVAudioQuality.high.rawValue
                        ]
                        
                        self.recorder = try AVAudioRecorder(url: fileName, settings: settings)
                        self.recorder.record()
                        self.record.toggle()
                    }
                    catch {
                        print(error.localizedDescription)
                    }
                },
                       label: {
                            Image(systemName: "mic.circle.fill")
                                .resizable()
                                .frame(width: 100, height: 100)
                                .foregroundColor(.red)
                                //.shadow(color: .secondary, radius: 5, x: -5, y: 5)
                          })
            }
            .navigationBarTitle("Voice Note")
        }
        .alert(isPresented: self.$alert, content: {
            Alert(title: Text("ERROR"), message: Text("Access Denied"))
        })
        .onAppear {
            do {
                self.session = AVAudioSession.sharedInstance()
                try self.session.setCategory(.playAndRecord)
                
                self.session.requestRecordPermission { (status) in
                    
                    if !status {
                        self.alert.toggle()
                    } else {
                        self.getRecordings()
                    }
                }
            }
            catch {
                print(error.localizedDescription)
            }
        }
       
    }
    func getRecordings() {
        
        do {
            let url = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
            
            let result = try FileManager.default.contentsOfDirectory(at: url, includingPropertiesForKeys: nil, options: .producesRelativePathURLs)
            
            self.recordings.removeAll()
            
            for i in result {
                self.recordings.append(i)
            }
        } catch {
            print(error.localizedDescription)
        }
    }
}
