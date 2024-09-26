local status = game.Workspace.Status

script.Parent.Text = status.Value
status.Changed:Connect(function()
    script.Parent.Text = status.Value
end)