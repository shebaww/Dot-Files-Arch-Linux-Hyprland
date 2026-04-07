function onDeviceChanged()
  os.execute("mpv --no-video ~/.local/share/sounds/plug.wav")
end
wpctl status | grep "USB" && onDeviceChanged()
