
import SwiftUI
import RealmSwift

struct ConversationMembership: View {
    
    @EnvironmentObject var state: AppState
    @Environment(\.presentationMode) var presentationMode
    @ObservedResults(Chatster.self) var chatsters
    @ObservedRealmObject var conversation : Conversation
    
    var isPreview = false
    
    @State private var name = ""
    @State private var members = [String]()
    @State private var candidateMember = ""
    @State private var candidateMembers = [String]()
    
    init(conversation: conversation) {
        self.conversation = conversation
        for member in  conversation.members {
        members.append(member.email)
        }
    }
    
    private var isEmpty: Bool {
        !(members.count > 0)
    }
    
    private var usersList: [String] {
        candidateMember == ""
        ? chatsters.compactMap {
            state.user?.email != $0.email && !members.contains($0.email)
            ? $0.email
            : nil }
        : candidateMembers
    }
 
    var body: some View {
        let searchBinding = Binding<String>(
            get: { candidateMember },
            set: {
                candidateMember = $0
                searchUsers()
            }
        )
        
        return VStack{
        
            ZStack {
                VStack(spacing: 5) {
                    if let message = state.error {
                        Text (message).font(.caption)
                    }
                    CaptionLabel(title: "Add Members")
                    SearchBox(searchText: searchBinding)
                    if candidateMember.count > 5 {
                        List {
                            ForEach(usersList, id: \.self) { candidateMember in
                                
                                AddMemberButton(conversation: conversation, candidate: candidateMember)
                                        .environment(
                                            \.realmConfiguration,
                                            app.currentUser!.configuration(partitionValue: "user=\(state.user?._id ?? "")"))
                                
                            }
                        }.cornerRadius(10)
                    } else {
                        VStack{
                            Spacer()
                            Text("Please input user email (at least 5 characters)").font(.caption)
                            Spacer()
                        }.frame(maxWidth: .infinity)
                           
                            
                    }
                    CaptionLabel(title: "Members")
                    List {
                        ForEach(conversation.members, id: \.self) { member in
                            Text("\(member.email)")
                        }
                        .onDelete(perform: $conversation.members.remove)
                    }.cornerRadius(10)
                    Spacer()
                }
                Spacer()
                if let error = state.error {
                    Text("Error: \(error)")
                        .foregroundColor(Color.red)
                }
            }
            .padding()

        }
        .onAppear(perform: searchUsers)


    }
    
    private func searchUsers() {
        var candidatechatsters: Results<Chatster>
        if candidateMember == "" {
            candidatechatsters = chatsters
        } else {
            
            let predicate = NSPredicate(format: "email CONTAINS[cd] %@", candidateMember)
            candidatechatsters = chatsters.filter(predicate)
            
            }
        candidateMembers = []
        candidatechatsters.forEach { Chatster in
            if !members.contains(Chatster.email) && Chatster.email != state.user?.email {
                candidateMembers.append(Chatster.email)
            }
        }
        
    }

}
    
 
