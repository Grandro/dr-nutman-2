extends Node

class_name CurveGenerator

static func generate_circle(p_radius, p_points_amount, p_step_amount):
	var curve = Curve3D.new()
	
	var angle = 1.0/2 * PI
	var step = 2.0*PI / p_step_amount
	for i in p_points_amount:
		var x = p_radius * sin(angle) - p_radius
		var y = p_radius * cos(angle) #- p_radius
		var point = Vector3(x, 0.0, y)
		curve.add_point(point)
		
		angle += step
	
	return curve
