//
//  AppPickerView.swift
//  VisitShareExtension
//
//  SwiftUI view for selecting target app and previewing/editing text
//

import Foundation
import SwiftUI

struct AppPickerView:View
{
    
    // MARK:- Properties...
    
    @State var messageText:String
           let onSelect:(VVSharedTargetApps, String)->Void
           let onCancel:()->Void
    
    @State      private var selectedApp:VVSharedTargetApps?
    @State      private var isEditing:Bool                   = false
    @FocusState private var textEditorFocused:Bool
    
    // MARK:- Body
    
    var body:some View
    {

        NavigationView
        {
            VStack(spacing:0)
            {
                ScrollView
                {
                    VStack(spacing:20)
                    {
                        // Message preview/edit section...

                        messageSection
                        
                        // App picker section...

                        appPickerSection
                    }
                    .padding()
                }
                
            // Bottom action area...

            if (selectedApp != nil)
            {
                actionButton
            }
            }
            .navigationTitle("Share To")
            .navigationBarTitleDisplayMode(.inline)
            .toolbar
            {
                ToolbarItem(placement:.cancellationAction)
                {
                    Button("Cancel") { onCancel() }
                }
            }
        }

    }
    
    // MARK:- Message Section...
    
    private var messageSection:some View
    {
        VStack(alignment:.leading, spacing:8)
        {
            HStack 
            {
                Text("Message")
                    .font(.subheadline)
                    .fontWeight(.medium)
                Spacer()
                Button(action:
                       {
                           isEditing.toggle()

                           if isEditing
                           {
                               textEditorFocused = true
                           }
                       })
                {
                    Text(isEditing ? "Done" :"Edit")
                        .font(.subheadline)
                }
            }
            
        if isEditing
        {
            TextEditor(text:$messageText)
                .font(.body)
                .frame(minHeight:100, maxHeight:200)
                .padding(8)
                .background(Color(.systemGray6))
                .cornerRadius(8)
                .focused($textEditorFocused)
        } 
        else
        {
            Text(messageText)
                .font(.body)
                .lineLimit(4)
                .padding(12)
                .frame(maxWidth:.infinity, alignment:.leading)
                .background(Color(.systemGray6))
                .cornerRadius(8)
        }
            
            HStack
            {
                Spacer()
                Text("\(messageText.count) characters")
                    .font(.caption2)
                    .foregroundColor(.secondary)
            }
        }
    }
    
    // MARK:- App Picker Section
    
    private var appPickerSection:some View
    {
        VStack(alignment:.leading, spacing:12)
        {
            Text("Send To")
                .font(.subheadline)
                .fontWeight(.medium)
            
            ForEach(VVSharedTargetApps.allCases) 
            { app in

                AppPickerRow(app:app,
                             isSelected:selectedApp == app,
                             onTap: { withAnimation(.easeInOut(duration:0.2)) { selectedApp = app } })

            }
        }
    }
    
    // MARK:- Action Button
    
    private var actionButton:some View
    {
        VStack(spacing:8)
        {
            Divider()
            
        if let app = selectedApp
        {
            Button(action:
                   {
                       onSelect(app, messageText)
                   })
            {
                HStack
                {
                    Image(systemName:app.iconName)
                    Text(app.actionDescription)
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth:.infinity)
                .padding()
                .background(app.brandColor)
                .cornerRadius(12)
            }
            .disabled(messageText.trimmingCharacters(in:.whitespacesAndNewlines).isEmpty)
            .padding(.horizontal)
            .padding(.bottom)
        }
        }
        .background(Color(.systemBackground))
    }

}   // End of struct AppPickerView:View.

// MARK:- App Picker Row...

struct AppPickerRow:View
{

    let app:VVSharedTargetApps
    let isSelected:Bool
    let onTap:()->Void
    
    var body:some View
    {

        Button(action:onTap)
        {
            HStack(spacing:12)
            {
                // App icon...

                Image(systemName:app.iconName)
                    .font(.title2)
                    .foregroundColor(app.brandColor)
                    .frame(width:44, height:44)
                    .background(app.brandColor.opacity(0.15))
                    .cornerRadius(10)
                
                // App info...

                VStack(alignment:.leading, spacing:2)
                {
                    Text(app.displayName)
                        .font(.body)
                        .fontWeight(.medium)
                        .foregroundColor(.primary)
                    Text(app.actionDescription)
                        .font(.caption)
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                // Selection indicator...

                Image(systemName:isSelected ? "checkmark.circle.fill" :"circle")
                    .font(.title2)
                    .foregroundColor(isSelected ? app.brandColor :Color(.systemGray3))
            }
            .padding(12)
            .background(RoundedRectangle(cornerRadius:12).fill(isSelected ? app.brandColor.opacity(0.1) : Color(.systemGray6)))
            .overlay(RoundedRectangle(cornerRadius:12).stroke(isSelected ? app.brandColor : Color.clear, lineWidth:2))
        }
        .buttonStyle(.plain)

    }

}   // End of struct AppPickerRow:View.

// MARK:- Preview...

#Preview 
{
    AppPickerView(messageText:"Patient Mrs. Johnson called - experiencing increased pain in left knee after yesterday's therapy session. Requesting callback as soon as possible.",
                  onSelect:
                  { app, text in

                      print("Selected:[\(app.displayName)] with text:[\(text)]...")
                  },
                  onCancel:{ print("Cancelled") })
}

