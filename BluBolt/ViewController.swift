//
//  ViewController.swift
//  Test
//
//  Created by Jay Sharma on 20/03/18.
//  Copyright © 2018 Jay Sharma. All rights reserved.
//

import Cocoa

class ViewController: NSViewController {

    //Controller outlets
    @IBOutlet weak var inputLocation: NSTextField!
    @IBOutlet weak var projectPath: NSPathControl!
    @IBOutlet weak var targetContainer: NSPopUpButton!
    @IBOutlet weak var targetEncoder: NSPopUpButton!
    @IBOutlet weak var targetLocation: NSTextField!
    @IBOutlet weak var stopButton: NSButton!
    @IBOutlet weak var buildButton: NSButton!
    @IBOutlet weak var spinner: NSProgressIndicator!
    @IBOutlet var outputText: NSTextView!
    @IBOutlet weak var executeShell: NSButton!
    
    @objc dynamic var isRunning = false
    var outputPipe:Pipe!
    var errorPipe:Pipe!
    var buildTask:Process!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        stopButton.isEnabled = false
        executeShell.isEnabled = false
        // Do any additional setup after loading the view.
    }
    
    @IBAction func startTask(_ sender: Any) {
        outputText.string = ""
        
        let append1 = "/usr/local/bin/ffmpeg -i "
        let append2 = inputLocation.stringValue.replacingOccurrences(of: " ", with: "\\ ")
        var arguments:String = ""
        arguments.append(append1)
        arguments.append(append2)
        arguments.append(" -c:v")
        
        if(targetEncoder.titleOfSelectedItem == "H.265 (x265)"){
            arguments.append(" libx265 ")
        }
        else if(targetEncoder.titleOfSelectedItem == "H.264 (x264)"){
            arguments.append(" libx264 ")
        }
        else if(targetEncoder.titleOfSelectedItem == "VP9 (libvpx-vp9)"){
            arguments.append(" libvpx-vp9 ")
        }
        
        arguments.append("/Users/Jay/Desktop/")
        let append3 = targetLocation.stringValue.replacingOccurrences(of: " ", with: "\\ ")
        arguments.append(append3)
        
        if(targetContainer.titleOfSelectedItem == "MKV"){
            arguments.append(".mkv")
        }
        else if (targetContainer.titleOfSelectedItem == "MP4"){
            arguments.append(".mp4")
        }
        else if (targetContainer.titleOfSelectedItem == "AVI"){
            arguments.append(".avi")
        }
        outputText.string = arguments
        
        buildButton.isEnabled = false
        stopButton.isEnabled=true
        spinner.startAnimation(self)
        
        var argumentsx:[String]=[]
        argumentsx.append(arguments)
        
        runScript(argumentsx)
    }
    
    @IBAction func stopTask(_ sender: Any) {
        if isRunning {
            buildTask.terminate()
        }
    }
    
    func runScript(_ arguments:[String]) {
        isRunning = true
        let taskQueue = DispatchQueue.global(qos: DispatchQoS.QoSClass.background)
        taskQueue.async {
            guard let path = Bundle.main.path(forResource: "BuildScript",ofType:"command") else {
                print("Unable to locate BuildScript.command")
                return
            }
            
            self.buildTask = Process()
            self.buildTask.launchPath = path
            self.buildTask.arguments = arguments
            
            self.buildTask.terminationHandler = {
                task in
                DispatchQueue.main.async(execute: {
                    self.buildButton.isEnabled = true
                    self.spinner.stopAnimation(self)
                    self.isRunning = false
                    self.executeShell.isEnabled = true
                    self.stopButton.isEnabled = false

                })
            }
            self.captureStandardOutputAndRouteToTextView(self.buildTask)
            self.buildTask.launch()
            self.buildTask.waitUntilExit()
        }
    }
    
    func captureStandardOutputAndRouteToTextView(_ task:Process) {
        outputPipe = Pipe()
        errorPipe = Pipe()
        task.standardOutput = outputPipe
        task.standardError = errorPipe
        
        outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        errorPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: outputPipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = self.outputPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            DispatchQueue.main.async(execute: {
                let previousOutput = self.outputText.string
                let nextOutput = previousOutput + "\n" + outputString
                self.outputText.string = nextOutput
                
                let range = NSRange(location:nextOutput.characters.count,length:0)
                self.outputText.scrollRangeToVisible(range)
                
            })
            
            self.outputPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
        NotificationCenter.default.addObserver(forName: NSNotification.Name.NSFileHandleDataAvailable, object: errorPipe.fileHandleForReading , queue: nil) {
            notification in
            
            let output = self.errorPipe.fileHandleForReading.availableData
            let outputString = String(data: output, encoding: String.Encoding.utf8) ?? ""
            
            DispatchQueue.main.async(execute: {
                let previousOutput = self.outputText.string
                let nextOutput = previousOutput + "\n" + outputString
                self.outputText.string = nextOutput
                
                let range = NSRange(location:nextOutput.characters.count,length:0)
                self.outputText.scrollRangeToVisible(range)
                
            })
            
            self.errorPipe.fileHandleForReading.waitForDataInBackgroundAndNotify()
        }
    }
    
    
    @IBAction func executeShell(_ sender: Any?) {
        let pasteboard = NSPasteboard.general
        NSPasteboard.general.clearContents()
        pasteboard.declareTypes([NSPasteboard.PasteboardType.string], owner: nil)
        NSPasteboard.general.setString(outputText.string, forType: NSPasteboard.PasteboardType.string)
        
        var clipboardItems: [String] = []
        for element in pasteboard.pasteboardItems! {
            if let str = element.string(forType: NSPasteboard.PasteboardType(rawValue: "public.utf8-plain-text")) {
                clipboardItems.append(str)
            }
        }
        
        NSWorkspace.shared.launchApplication("Terminal")
    }
    
    override var representedObject: Any? {
        didSet {
        // Update the view, if already loaded.
        }
    }
}

