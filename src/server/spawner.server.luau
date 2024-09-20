function partSpawner(args)
    local newPart = Instance.new("Part");
    newPart.Name = args.name or "Default Name"
    newPart.BrickColor = args.color or BrickColor.new("Really red")
    newPart.CFrame = args.pos or CFrame.new(0, 0.5, -90);
    newPart.Parent = game.Workspace
end

partSpawner({name = "Part 1", color = BrickColor.new("Teal"), pos = CFrame.new(-30, 0.5, -90)})
partSpawner({pos = CFrame.new(30, 0.5, -70)})
partSpawner({name = "Last Part", color = BrickColor.new("Moss")})