//
//  ViewController.swift
//  ImgDemo
//
//  Created by WangJianyu on 2017/2/8.
//  Copyright © 2017年 Jianyu Wang. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController,WKScriptMessageHandler,WKNavigationDelegate {

    let htmlUrl = "http://localhost:8888/webdemo/test.html"             // 本地服务器 测试需自行修改
    
    let igmDownloadUrl = "http://localhost:8888/wkwebview/test.png"     // 本地服务器 测试需自行修改
    
    var imgFilePath: String? {
        didSet {
            // KVO 当imgFilePath被赋值（图片资源被下载并且保存）后执行
            evaluateJStoChangeAttribute(targetId: "img", attribute: "src", changeValue: self.imgFilePath!)
        }
    }
    
    var webView:WKWebView! = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        installWKView()
        // 模拟低网速的情况下下载图片 （donwloadImg 在2秒后调用）
        Timer.scheduledTimer(timeInterval: 2, target: self, selector: #selector(donwloadImg), userInfo: nil, repeats: false)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }

    func installWKView() {

        let configuration = WKWebViewConfiguration()
//        configuration.preferences.javaScriptEnabled= false
        webView = WKWebView(frame: CGRect(x: 0, y: 30, width: UIScreen.main.bounds.width, height: UIScreen.main.bounds.height/2), configuration: configuration)
        webView.navigationDelegate = self
        self.view.addSubview(webView)
        
        //webView.load(request)
        //webView.load(URLRequest(url: URL(string: htmlUrl)!))
        let path = downloadAndSvaeFile(downLoadFromURL: NSURL(string: self.htmlUrl)!, fileName: "/index.html")
        webView.load(URLRequest(url: URL(fileURLWithPath: path)))
    }
    
    func donwloadImg() {
        self.imgFilePath = downloadAndSvaeFile(downLoadFromURL: NSURL(string: self.igmDownloadUrl)!, fileName: "/test.png")
    }
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("finish")
        let path = Bundle.main.path(forResource: "loading", ofType: ".png")
        evaluateJStoChangeAttribute(targetId: "img", attribute: "src", changeValue: path!)
    }
    
    
    /// 从URL下载并保存文件到 document目录下
    ///
    /// - Parameters:
    ///   - downLoadFromURL: 文件源
    ///   - fileName: 文件保存名（包括后缀）
    /// - Returns: 保存后的文件的路径
    private func downloadAndSvaeFile(downLoadFromURL: NSURL, fileName:String) -> String {
        let documentPaths = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.userDomainMask, true)
        let documentPath = documentPaths[0]
//        let url : NSURL = NSURL(string: downLoadFromURL)!
        let data : NSData = NSData(contentsOf:downLoadFromURL as URL)!
        data.write(toFile: documentPath+"/"+fileName, atomically: true)
        return (documentPath+"/"+fileName)
    }
    
    
    /// native调用webview修改特定id元素的属性
    ///
    /// - Parameters:
    ///   - targetId: id
    ///   - attribute: attribute
    ///   - changeValue: change value
    private func evaluateJStoChangeAttribute(targetId: String, attribute: String, changeValue: String) {
        let JSstr = "document.getElementById('\(targetId)').\(attribute)='\(changeValue)';"
        webView.evaluateJavaScript(JSstr, completionHandler: { (object, error) -> Void in
            print(error ?? "JS调用完成: ")
        })
    }
    
    
    /// 用来响应js的调用
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        
    }
}
