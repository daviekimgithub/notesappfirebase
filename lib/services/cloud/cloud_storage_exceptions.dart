class CloudStorageExceptions implements Exception {
  const CloudStorageExceptions();
}

class CouldNotCreateNoteException extends CloudStorageExceptions {}

class CouldNotGetAllNotesException extends CloudStorageExceptions {}

class CouldNotDeleteNoteException extends CloudStorageExceptions {}

class CouldNotUpdateNoteException extends CloudStorageExceptions {}
