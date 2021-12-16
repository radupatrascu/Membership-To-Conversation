
import SwiftUI
import RealmSwift

struct AddMemberButton: View {
    @EnvironmentObject var state: AppState
    @Environment(\.realm) var userRealm
    @ObservedRealmObject var conversation: Conversation
    
    var candidate: String
    
    var body: some View {
        Button(action: {
        
        addMember(candidate)

        }) {
            HStack {
                Text(candidate)
                Spacer()
                Image(systemName: "plus.circle.fill")
                    .renderingMode(.original)
            }
        }
    }
    
    func addMember(_ member: String){
        state.error = nil
        state.shouldIndicateActivity = true
        if conversation.members.contains(where: {$0.email != member}) {
            $conversation.members.append(Member(email: member, state: .pending))
        }
        state.shouldIndicateActivity = false
    }
}


