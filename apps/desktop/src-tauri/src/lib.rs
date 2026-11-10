use aico_platform::list_volumes;

#[tauri::command]
fn list_volumes_cmd() -> Vec<aico_platform::MountedVolume> {
    list_volumes()
}

#[cfg_attr(mobile, tauri::mobile_entry_point)]
pub fn run() {
    tauri::Builder::default()
        .plugin(tauri_plugin_shell::init())
        .invoke_handler(tauri::generate_handler![list_volumes_cmd])
        .run(tauri::generate_context!())
        .expect("error running AIcoSystem");
}
