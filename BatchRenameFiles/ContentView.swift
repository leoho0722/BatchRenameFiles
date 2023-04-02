//
//  ContentView.swift
//  BatchRenameFiles
//
//  Created by Leo Ho on 2023/4/2.
//

import SwiftUI

struct ContentView: View {
    
    @State private var dirctoryPath: String = ""
    
    @State private var filenameFormat: String = ""
    
    @State private var filenameStartNum: String = ""
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text("資料夾路徑：" + dirctoryPath)
                Button {
                    if let openURL = showOpenPanel() {
                        dirctoryPath = openURL.absoluteString
                    }
                } label: {
                    Text("瀏覽")
                }

            }
            HStack {
                HStack {
                    Text("檔案名稱格式")
                    TextField("檔案名稱格式", text: $filenameFormat)
                }
                HStack {
                    Text("檔案名稱編號")
                    TextField("檔案名稱編號", text: $filenameStartNum)
                }
                RenameButton()
                    .renameAction {
                        print(dirctoryPath)
                        batchedRename(dirctoryPath: dirctoryPath,
                                      format: filenameFormat,
                                      start: filenameStartNum)
                    }
            }
        }
        .padding()
        .frame(minWidth: 500, minHeight: 100)
    }
}

extension ContentView {
    
    private func showOpenPanel() -> URL? {
        let openPanel = NSOpenPanel()
        openPanel.allowedContentTypes = [
            .jpeg, .png, .heic, .webP, .image, .rawImage,
            .mpeg4Movie, .quickTimeMovie, .heif, .movie, .video,
            .folder
        ]
        openPanel.allowsMultipleSelection = false
        openPanel.canChooseDirectories = true
        openPanel.canChooseFiles = false
        let response = openPanel.runModal()
        return response == .OK ? openPanel.url : nil
    }
    
    private func batchedRename(dirctoryPath: String,
                               format filenameFormat: String,
                               start startIndex: String) {
        let fileManager = FileManager.default
        guard let path = URL(string: dirctoryPath) else {
            return
        }
        guard var index = Int(startIndex) else {
            return
        }
        do {
            print(path.absoluteString)
            let fileURLs = try fileManager.contentsOfDirectory(at: path,
                                                               includingPropertiesForKeys: [.nameKey, .contentModificationDateKey],
                                                               options: .skipsHiddenFiles)
            try fileURLs.forEach { oldURL in
                print("oldURL_\(index)：",oldURL)
                let oldName = oldURL.lastPathComponent
                let oldExtension = oldName.split(separator: ".")
                #if DEBUG
                print(oldExtension)
                print(String(describing: oldExtension.last))
                #endif
                if oldExtension.count > 1, let fileExtension = oldExtension.last {
                    #if DEBUG
                    print("fileExtension：",String(fileExtension))
                    #endif
                    let newName = filenameFormat + "\(index)" + ".\(String(fileExtension))"
                    #if DEBUG
                    print("newName：",newName)
                    #endif

                    let newURL = path.appendingPathComponent(newName)
                    try fileManager.moveItem(at: oldURL, to: newURL)
                    index += 1
                }
            }
        } catch {
            print("Error while enumerating files \(path.path): \(error.localizedDescription)")
        }
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
