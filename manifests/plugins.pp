define uber::plugins (
  $plugins,
  $plugins_dir,
  $user,
  $group,
) {
  $plugin_defaults = {
    'user'        => $user,
    'group'       => $group,
    'plugins_dir' => $plugins_dir,
  }
  create_resources(uber::plugin, $plugins, $plugin_defaults)
}
