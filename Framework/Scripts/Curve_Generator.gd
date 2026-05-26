extends Node
class_name FWCurveGenerator

static func generate_circle(p_radius: float, p_points_amount: int, p_step_amount: int) -> Curve3D:
	var curve: Curve3D = Curve3D.new()
	var angle: float = 0.5 * PI
	var step: float = 2.0 * PI / p_step_amount
	for i: int in p_points_amount:
		var x: float = p_radius * sin(angle) - p_radius
		var y: float = p_radius * cos(angle) #- p_radius
		var point: Vector3 = Vector3(x, 0.0, y)
		curve.add_point(point)
		
		angle += step
	
	return curve
