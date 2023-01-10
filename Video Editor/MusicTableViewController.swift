//
//  MusicTableViewController.swift
//  Video Editor
//
//  Created by Владимир Воробьев on 21.11.2022.
//

import UIKit
import MediaPlayer

protocol MusicTableViewControllerDelegate {
    
    func musicDidChosen ()
    
    func soundListUpdate (_ urls: [URL], _ title: [String])
    
}

class MusicTableViewController: UITableViewController {
    
    var delegate: MusicTableViewControllerDelegate?
    
    var fileManager = FileManager.default
   
    var tableData: [(section: String, labelText: [String])] = []
    var soundListUrls: [URL] = []
    var soundListNames: [String] = []
    var soundListUpdateFromVC: [(title: String, url: URL)] = []
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
 
        var listUrl: [URL] = []
        var listTitle: [String] = []
        for item in soundListUpdateFromVC {
            listUrl.append(item.url)
            listTitle.append(item.title)
        }
        
        soundListUrls = listUrl
        soundListNames = listTitle

        self.tableData = [("Добавьте файлы в список", ["Медиатека (только купленные)", "Файлы"]), ("Выбранные файлы", soundListNames)]
    }

    @IBAction func readyButton(_ sender: Any) {
        self.delegate?.soundListUpdate(self.soundListUrls, self.soundListNames)
        self.delegate?.musicDidChosen()



        self.presentingViewController?.dismiss(animated: true, completion: nil)
    }
    

    override func numberOfSections(in tableView: UITableView) -> Int {

        return tableData.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        
        tableData[section].labelText.count
    }
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        
        return tableData[section].section
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 60
    }
    
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 60
        
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "MusicTabelVIewCell", for: indexPath) as! MusicTableViewCell
        let data = tableData
        let text = data[indexPath.section].labelText[indexPath.row]
        
        cell.label.text = text
        
        if indexPath.section == 0 {
            if indexPath.row == 0 {
                cell.iconImageView.image = UIImage(systemName: "music.note.list")
            } else {
                cell.iconImageView.image = UIImage(systemName: "folder.fill")
            }
        } else {
            cell.iconImageView.image = UIImage(systemName: "music.note")
        }

        
        
        return cell
    }
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0{
            if indexPath.row == 0 {
                chooseAssetInMediaPlayer()
            } else {
                chooseFileInDocPicker()
            }
        } else {
            if tableData[1].labelText.count > 1 {
                tableView.isEditing = true
            } 
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    

  
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        
        if indexPath.section == 0 {
            return false
        } else {return true}
        
        
    }



    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableData[indexPath.section].labelText.remove(at: indexPath.row)
            soundListUrls.remove(at: indexPath.row)
            soundListNames.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .fade)
   
        }

    }

    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        if indexPath.section == 0 {
            return false
        } else {return true}
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        let temp = tableData[sourceIndexPath.section].labelText[sourceIndexPath.row]
        let tempUrl = soundListUrls[sourceIndexPath.row]
        
        tableData[sourceIndexPath.section].labelText.remove(at: sourceIndexPath.row)
        soundListNames.remove(at: sourceIndexPath.row)
        soundListUrls.remove(at: sourceIndexPath.row)
        
        tableData[destinationIndexPath.section].labelText.insert(temp, at: destinationIndexPath.row)
        soundListNames.insert(temp, at: destinationIndexPath.row)
        soundListUrls.insert(tempUrl, at: destinationIndexPath.row)

        tableView.isEditing = false
    }
       
    func chooseAssetInMediaPlayer () {
        
        let picker = MPMediaPickerController(mediaTypes: .anyAudio)
        picker.delegate = self
        picker.showsCloudItems = true
        picker.showsItemsWithProtectedAssets = true
        picker.popoverPresentationController?.sourceView = view
        present(picker, animated: true, completion: nil)
    }
    
    func chooseFileInDocPicker () {
        let documentPicker = UIDocumentPickerViewController(forOpeningContentTypes: [UTType.aiff, UTType.mp3, UTType.midi, UTType.wav, UTType.audio])
        documentPicker.delegate = self
        documentPicker.allowsMultipleSelection = false
        present(documentPicker, animated: true, completion: nil)
    }
    
    func getNameFromUrl (_ url: URL) -> String {
        var path = url.absoluteString
        var name = ""
        var letter = path.last
        while letter != "/"  {
            name.insert(path.removeLast(), at: name.startIndex)
            if path.count == 0 {break}
            letter = path.last
                }
        return name.replacingOccurrences(of: "%20", with: " ")
    }
    
    func getTitelFromPMItem (_ item: MPMediaItem) -> String{
        if let songTitle = item.value(forProperty: MPMediaItemPropertyTitle) as? String {
            return songTitle
        } else {
            return "UnKnown"
        }
    }

}

func getUrlFromMPMediaItem (_ item: MPMediaItem, _  completionHandler: @escaping (_ url: URL?)->Void) {
    
    let url = item.assetURL
    completionHandler(url)
}

extension MusicTableViewController: UIDocumentPickerDelegate {
    
    func documentPicker(_ controller: UIDocumentPickerViewController, didPickDocumentsAt urls: [URL]) {

        for url in urls {
         soundListUrls.append(url)
         let selectedFilePath = url.absoluteString
         let name = fileManager.displayName(atPath: selectedFilePath).replacingOccurrences(of: "%20", with: " ")
         soundListNames.append(name)
         tableData[1].labelText.append(name)
        }
        tableView.reloadData()
    }

}

extension MusicTableViewController: MPMediaPickerControllerDelegate {
    
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        
        let items = mediaItemCollection.items
        for item in items {
            if let url = item.assetURL{
                soundListUrls.append(url)
                let artist = item.artist ?? ""
                let title = item.title ?? "unknown"
                let fullName = artist + " - " + title
                soundListNames.append(fullName)
                tableData[1].labelText.append(fullName)
            } else {
                alertCall(mediaPicker, "Внимание", VideoEditorErrors.urlClosed.rawValue)
                return 
            }
           
        }
        mediaPicker.dismiss(animated: true, completion: nil)
        tableView.reloadData()
        
    }
}
