////
////  ManageImages
////
////  Created by Bharti Sagar on 22/11/24.
////
//
//import RealmSwift
//
//let config = Realm.Configuration(
//    schemaVersion: 2, // Increment this version number
//    migrationBlock: { migration, oldSchemaVersion in
//        if oldSchemaVersion < 2 {
//            // Handle any required schema changes. For example:
//            // - If 'id' was removed, no migration is required as it's simply gone.
//            // - Similarly, 'imageData' and the primary key are removed.
//            migration.enumerateObjects(ofType: CapturedImage.className()) { oldObject, newObject in
//                // Handle any necessary migration logic if fields were changed.
//                // Example: If you had to migrate data (e.g. from old fields to new), do it here.
//                // Currently no fields need explicit migration, just make sure Realm recognizes the changes.
//            }
//        }
//    }
//)
//
//// Apply the configuration globally
////Realm.Configuration.defaultConfiguration = config
