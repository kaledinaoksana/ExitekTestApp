//
//  ContentView.swift
//  Exitek
//
//  Created by Oksana Kaledina on 02.09.2022.
//

import SwiftUI

enum ContainedViewType{
    case start
    case notFoundElement
    case foundElement
    case getAllElement
    case elementExist
    case noValue
}

struct TestContentView: View {
    
    @State var imei = ""
    @State var model = ""
    @State var difImei = ""
    @State var difModel = ""
    @State var exists = false
    @State var containedViewType: ContainedViewType = .start
    @State var message = ""
    @FocusState var isInputActive: Bool
    
    let storage = StorageManager.shared
    var data: Set<Mobile> {
        get{
            return storage.getAll()
        }
    }
    

    var body: some View {
        
        VStack(spacing: 15){
            
            VStack{
                HStack(alignment: .firstTextBaseline){
                    Text("Mobile IMEI:")
                    TextField("", text: $imei)
                        .textFieldStyle(.roundedBorder)
                }
                HStack(alignment: .firstTextBaseline){
                    Text("Mobile model:")
                    TextField("", text: $model)
                        .textFieldStyle(.roundedBorder)
                }
            }
            .keyboardType(.alphabet)
            .disableAutocorrection(true)
            .padding()
            .focused($isInputActive)
            .toolbar {
                ToolbarItemGroup(placement: .keyboard){
                    Spacer()
                    Button("Done"){
                        containedViewType = .start
                        difImei.self = imei.self
                        difModel.self = model.self
                        isInputActive = false
                    }
                }
            }
            
            HStack{
                Button(action: saveData){Text("Save")}
                Spacer()
                Button(action: deleteItem){Text("Delete")}
                Spacer()
                Button(action: findImei){Text("Find by imei")}
                Spacer()
                Button(action: existMobile){Text("Exists")}
            }
            .padding()
            
            Button(
                action: {containedViewType.self = .getAllElement}
            ){Text("Get all mobiles")}

        }
        .padding()

        containedView()
        Spacer()
    }
    
    func saveData(){
        do{
            let mob = try storage.save(Mobile(imei: difImei, model: difModel))
            message.self = "Saved imei: \(mob.imei), model: \(mob.model)"
            containedViewType.self = .noValue
        } catch {
            message.self = "imei must be unique"
            containedViewType.self = .noValue
        }
    }
    
    func deleteItem(){
        do{
            try storage.delete(Mobile(imei: difImei, model: difModel))
            message.self = "Deleted imei: \(difImei), model: \(difModel)"
            containedViewType.self = .noValue
        } catch {
            message.self = "no mobile for delete"
            containedViewType.self = .noValue
        }
    }
    
    func findImei(){
        if difImei != "" {
            if let mobileFound = storage.findByImei(difImei) {
                difModel.self = mobileFound.model
                difImei.self = mobileFound.imei
                containedViewType.self = .foundElement
            } else {
                containedViewType.self = .notFoundElement
            }
        } else {
            message.self = "no value in imei"
            containedViewType.self = .noValue
        }
    }
    
    func existMobile(){
        if difImei == "" || difModel == "" {
            message.self = "no value"
            containedViewType.self = .noValue
        } else {
            exists.self = storage.exists(Mobile(imei: difImei, model: difModel))
            containedViewType.self = .elementExist
        }
    }
    
     func containedView() -> AnyView {
         switch containedViewType {
             case .start: return AnyView(Spacer())
             case .notFoundElement: return AnyView(NoFoundView(data: difImei.self))
             case .getAllElement: return AnyView(AllMobileView(data: data.self))
             case .elementExist: return AnyView(
                ExistView(
                    data: Mobile(imei: difImei.self, model: difModel.self),
                    exist: exists.self
                )
             )
             case .foundElement: return AnyView(
                FoundView(data: Mobile(imei: difImei.self, model: difModel.self))
             )
         case .noValue: return AnyView(Text(message.self).font(.title))
         }
     }
     
}


struct AllMobileView: View{
    let data: Set<Mobile>
    var body: some View {
        VStack {
            List {
                ForEach(Array(data),id: \.self) { mobile in
                    VStack(alignment: .leading){
                        Text("Imei: \(mobile.imei)")
                        Text("Mobile model: \(mobile.model)")
                    }
                }
            }
        }
    }
}

struct NoFoundView: View{
    let data: String
    var body: some View {
        VStack(alignment: .leading){
            Text("ELEMENT IS NOT FOUND")
                .bold()
            Text("Imei: \(data)")
        }
        .font(.title)
    }
}

struct FoundView: View{
    let data: Mobile
    var body: some View {
        VStack(alignment: .leading){
            Text("ELEMENT IS FOUND")
                .bold()
            Text("Imei: \(data.imei)")
            Text("Mobile model: \(data.model)")
        }
        .font(.title)
    }
}

struct ExistView: View{
    let data: Mobile
    let exist: Bool
    var body: some View {
        VStack(alignment: .leading){
            Text("Is exist? - \(String(exist))")
                .bold()
            Text("Imei: \(data.imei)")
            Text("Mobile model: \(data.model)")
        }
        .font(.title)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        TestContentView()
    }
}
