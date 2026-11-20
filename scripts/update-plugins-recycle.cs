using System;
using System.IO;
using System.Runtime.InteropServices;
namespace GalaxyUpdater {
 [ComImport, Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
 public interface IShellItem {}
 [ComImport, Guid("947AAB5F-0A5C-4C13-B4D6-4BF7836FC9F8"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
 public interface IFileOperation {
  void Advise(IntPtr sink, out uint cookie); void Unadvise(uint cookie);
  void SetOperationFlags(uint flags); void SetProgressMessage([MarshalAs(UnmanagedType.LPWStr)] string text);
  void SetProgressDialog(IntPtr dialog); void SetProperties(IntPtr properties); void SetOwnerWindow(uint owner);
  void ApplyPropertiesToItem(IShellItem item); void ApplyPropertiesToItems(IntPtr items);
  void RenameItem(IShellItem item, [MarshalAs(UnmanagedType.LPWStr)] string name, IntPtr sink);
  void RenameItems(IntPtr items, [MarshalAs(UnmanagedType.LPWStr)] string name);
  void MoveItem(IShellItem item, IShellItem target, [MarshalAs(UnmanagedType.LPWStr)] string name, IntPtr sink);
  void MoveItems(IntPtr items, IShellItem target);
  void CopyItem(IShellItem item, IShellItem target, [MarshalAs(UnmanagedType.LPWStr)] string name, IntPtr sink);
  void CopyItems(IntPtr items, IShellItem target);
  void DeleteItem(IShellItem item, IFileOperationProgressSink sink); void DeleteItems(IntPtr items);
  void NewItem(IShellItem target, uint attributes, [MarshalAs(UnmanagedType.LPWStr)] string name, [MarshalAs(UnmanagedType.LPWStr)] string template, IntPtr sink);
  void PerformOperations(); void GetAnyOperationsAborted([MarshalAs(UnmanagedType.Bool)] out bool aborted);
 }
 [ComVisible(true), Guid("04B0F1A7-9490-44BC-96E1-4296A31252E2"), InterfaceType(ComInterfaceType.InterfaceIsIUnknown)]
 public interface IFileOperationProgressSink {
  [PreserveSig] int StartOperations(); [PreserveSig] int FinishOperations(int result);
  [PreserveSig] int PreRenameItem(uint flags, IShellItem item, [MarshalAs(UnmanagedType.LPWStr)] string name);
  [PreserveSig] int PostRenameItem(uint flags, IShellItem item, [MarshalAs(UnmanagedType.LPWStr)] string name, int result, IShellItem created);
  [PreserveSig] int PreMoveItem(uint flags, IShellItem item, IShellItem target, [MarshalAs(UnmanagedType.LPWStr)] string name);
  [PreserveSig] int PostMoveItem(uint flags, IShellItem item, IShellItem target, [MarshalAs(UnmanagedType.LPWStr)] string name, int result, IShellItem created);
  [PreserveSig] int PreCopyItem(uint flags, IShellItem item, IShellItem target, [MarshalAs(UnmanagedType.LPWStr)] string name);
  [PreserveSig] int PostCopyItem(uint flags, IShellItem item, IShellItem target, [MarshalAs(UnmanagedType.LPWStr)] string name, int result, IShellItem created);
  [PreserveSig] int PreDeleteItem(uint flags, IShellItem item);
  [PreserveSig] int PostDeleteItem(uint flags, IShellItem item, int result, IShellItem created);
  [PreserveSig] int PreNewItem(uint flags, IShellItem target, [MarshalAs(UnmanagedType.LPWStr)] string name);
  [PreserveSig] int PostNewItem(uint flags, IShellItem target, [MarshalAs(UnmanagedType.LPWStr)] string name, [MarshalAs(UnmanagedType.LPWStr)] string template, uint attributes, int result, IShellItem created);
  [PreserveSig] int UpdateProgress(uint total, uint done);
  [PreserveSig] int ResetTimer(); [PreserveSig] int PauseTimer(); [PreserveSig] int ResumeTimer();
 }
 [ComVisible(true), ClassInterface(ClassInterfaceType.None)]
 public class RecycleSink : IFileOperationProgressSink {
  public bool Completed; public bool Refused; public int Failure;
  public int StartOperations(){return 0;} public int FinishOperations(int r){if(r<0)Failure=r;return 0;}
  public int PreRenameItem(uint f,IShellItem i,string n){return 0;}
  public int PostRenameItem(uint f,IShellItem i,string n,int r,IShellItem c){return 0;}
  public int PreMoveItem(uint f,IShellItem i,IShellItem t,string n){return 0;}
  public int PostMoveItem(uint f,IShellItem i,IShellItem t,string n,int r,IShellItem c){return 0;}
  public int PreCopyItem(uint f,IShellItem i,IShellItem t,string n){return 0;}
  public int PostCopyItem(uint f,IShellItem i,IShellItem t,string n,int r,IShellItem c){return 0;}
  // Refuse a permanent delete BEFORE it happens, including a Shell fallback.
  public int PreDeleteItem(uint f,IShellItem i){if((f & 0x80)==0){Refused=true;return unchecked((int)0x80004004);}return 0;}
  public int PostDeleteItem(uint f,IShellItem i,int r,IShellItem c){if(r<0)Failure=r;else Completed=true;return 0;}
  public int PreNewItem(uint f,IShellItem t,string n){return 0;}
  public int PostNewItem(uint f,IShellItem t,string n,string p,uint a,int r,IShellItem c){return 0;}
  public int UpdateProgress(uint t,uint d){return 0;} public int ResetTimer(){return 0;}
  public int PauseTimer(){return 0;} public int ResumeTimer(){return 0;}
 }
 public static class RecycleOnly {
  [DllImport("shell32.dll", CharSet=CharSet.Unicode, PreserveSig=false)]
  static extern void SHCreateItemFromParsingName(string path,IntPtr context,ref Guid iid,[MarshalAs(UnmanagedType.Interface)] out IShellItem item);
  public static void Send(string path) {
   IFileOperation op=null; IShellItem item=null;
   try {
    op=(IFileOperation)Activator.CreateInstance(Type.GetTypeFromCLSID(new Guid("3AD05575-8857-4850-9277-11B85BDB8E09")));
    // RECYCLEONDELETE, EARLYFAILURE, NOERRORUI, SILENT, NOCONFIRMATION.
    op.SetOperationFlags(0x00080000 | 0x00100000 | 0x0400 | 0x0004 | 0x0010);
    Guid iid=new Guid("43826D1E-E718-42EE-BC55-A1E261C37BFE");
    SHCreateItemFromParsingName(path,IntPtr.Zero,ref iid,out item);
    var sink=new RecycleSink(); op.DeleteItem(item,sink); op.PerformOperations();
    bool aborted; op.GetAnyOperationsAborted(out aborted);
    if(sink.Refused || aborted || !sink.Completed || sink.Failure<0) throw new IOException("Recycle Bin operation refused or failed. No permanent-delete fallback is allowed.");
   } finally {if(item!=null)Marshal.ReleaseComObject(item);if(op!=null)Marshal.ReleaseComObject(op);}
  }
 }
}
