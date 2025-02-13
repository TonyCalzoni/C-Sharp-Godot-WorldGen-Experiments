using Godot;
using System;
// using System.Numerics;

public partial class player : CharacterBody2D
{
	// @export in C# is: [Export]
	[Export] public int speed { get; set; } = 1000;

	public override void _Process(double delta)
	{
		base._Process(delta);
	}

	public override void _PhysicsProcess(double _delta)
	{
		GetInput();
		MoveAndSlide();
	}

	public void GetInput()
	{
		Vector2 inputDirection = Input.GetVector("left", "right", "up", "down");
		Velocity = inputDirection * speed;
	}
}
