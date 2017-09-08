//
//  Vector.swift
//  Raytracer
//
//  Created by Julian Dunskus on 25.08.17.
//  Copyright © 2017 Julian Dunskus. All rights reserved.
//

import Foundation

infix operator •: MultiplicationPrecedence
infix operator ×: MultiplicationPrecedence

extension Numeric {
	var squared: Self {
		return self * self
	}
}

protocol Vector {
	associatedtype Component: FloatingPoint
	
	static func +=(lhs: inout Self, rhs: Self)
	static func *=(vec: inout Self, scale: Component)
	static func *=(lhs: inout Self, rhs: Self) // componentwise multiplication
	static func •(lhs: Self, rhs: Self) -> Component // dot product
	var squaredSum: Component { get }
	
	// generated by extension
	static prefix func -(vec: Self) -> Self
	static func +(lhs: Self, rhs: Self) -> Self
	static func -(lhs: Self, rhs: Self) -> Self
	static func *(scale: Component, vec: Self) -> Self
	static func *(vec: Self, scale: Component) -> Self
	static func *(lhs: Self, rhs: Self) -> Self
	static func /(vec: Self, scale: Component) -> Self
	var norm: Component { get }
	var normalized: Self { get }
}

extension Vector {
	static func -(lhs: Self, rhs: Self) -> Self {
		return lhs + -rhs
	}
	
	static func /(vec: Self, scale: Component) -> Self {
		return vec * (1 / scale)
	}
	
	var norm: Component {
		return squaredSum.squareRoot()
	}
	
	var normalized: Self {
		return (1 / norm) * self
	}
}

protocol Struct {}

extension Vector where Self: Struct {
	static func +(lhs: Self, rhs: Self) -> Self {
		var copy = lhs
		copy += rhs
		return copy
	}
	
	static func *(scale: Component, vec: Self) -> Self {
		var copy = vec
		copy *= scale
		return copy
	}
	
	static func *(vec: Self, scale: Component) -> Self {
		var copy = vec
		copy *= scale
		return copy
	}
	
	static func *(lhs: Self, rhs: Self) -> Self {
		var copy = lhs
		copy *= rhs
		return copy
	}
}

protocol LazyVector {
	associatedtype Component: Numeric
	static var componentPaths: [WritableKeyPath<Self, Component>] { get }
}

extension Vector where Self: LazyVector {
	static prefix func -(vec: Self) -> Self {
		return -1 * vec
	}
	
	static func +=(lhs: inout Self, rhs: Self) {
		for path in componentPaths {
			lhs[keyPath: path] += rhs[keyPath: path]
		}
	}
	
	static func *=(vec: inout Self, scale: Component) {
		for path in componentPaths {
			vec[keyPath: path] *= scale
		}
	}
	
	static func *=(lhs: inout Self, rhs: Self) {
		for path in componentPaths {
			lhs[keyPath: path] *= rhs[keyPath: path]
		}
	}
	
	static func •(lhs: Self, rhs: Self) -> Component {
		var result: Component = 0
		for path in componentPaths {
			result += lhs[keyPath: path] * rhs[keyPath: path]
		}
		return result
	}
	
	var squaredSum: Component {
		return Self.componentPaths
			.map { self[keyPath: $0].squared }
			.reduce(0, +)
	}
}

typealias F = Double

struct Vector2: Struct, LazyVector, Vector {
	static let componentPaths = [\Vector2.x, \.y]
	var x, y: F
}

struct Vector3: Struct, Vector {
	static let zero = Vector3(x: 0, y: 0, z: 0)
	var x, y, z: F
	
	init(x: F, y: F, z: F) {
		self.x = x
		self.y = y
		self.z = z
	}
	
	static prefix func -(vec: Vector3) -> Vector3 {
		return Vector3(x: -vec.x, y: -vec.y, z: -vec.z)
	}
	
	static func ×(lhs: Vector3, rhs: Vector3) -> Vector3 {
		return Vector3(x: lhs.y * rhs.z - lhs.z * rhs.y,
		               y: lhs.z * rhs.x - lhs.x * rhs.z,
		               z: lhs.x * rhs.y - lhs.y * rhs.x)
	}
	
	static func +=(lhs: inout Vector3, rhs: Vector3) {
		lhs.x += rhs.x
		lhs.y += rhs.y
		lhs.z += rhs.z
	}
	
	static func -=(lhs: inout Vector3, rhs: Vector3) {
		lhs.x -= rhs.x
		lhs.y -= rhs.y
		lhs.z -= rhs.z
	}
	
	static func *=(vec: inout Vector3, scale: F) {
		vec.x *= scale
		vec.y *= scale
		vec.z *= scale
	}
	
	static func *=(lhs: inout Vector3, rhs: Vector3) {
		lhs.x *= rhs.x
		lhs.y *= rhs.y
		lhs.z *= rhs.z
	}
	
	static func •(lhs: Vector3, rhs: Vector3) -> F {
		return lhs.x * rhs.x + lhs.y * rhs.y + lhs.z * rhs.z
	}
	
	var squaredSum: F {
		return x.squared + y.squared + z.squared
	}
	
	//	static func +(lhs: Vector3, rhs: Vector3) -> Vector3 {
	//		return Vector3(x: lhs.x + rhs.x,
	//		               y: lhs.y + rhs.y,
	//		               z: lhs.z + rhs.z)
	//	}
	//	
	//	static func *(scale: Double, vec: Vector3) -> Vector3 {
	//		return Vector3(x: vec.x * scale,
	//		               y: vec.y * scale,
	//		               z: vec.z * scale)
	//	}
	//	
	//	static func *(vec: Vector3, scale: Double) -> Vector3 {
	//		return Vector3(x: vec.x * scale,
	//		               y: vec.y * scale,
	//		               z: vec.z * scale)
	//	}
	//	
	//	static func *(lhs: Vector3, rhs: Vector3) -> Vector3 {
	//		return Vector3(x: lhs.x * rhs.x,
	//		               y: lhs.y * rhs.y,
	//		               z: lhs.z * rhs.z)
	//	}
}

let formatter: NumberFormatter = {
	let formatter = NumberFormatter()
	formatter.maximumFractionDigits = 3
	return formatter
}()

extension Vector3: CustomStringConvertible {
	
	var description: String {
		let xString = formatter.string(from: x as NSNumber)!
		let yString = formatter.string(from: y as NSNumber)!
		let zString = formatter.string(from: z as NSNumber)!
		return "(\(xString), \(yString), \(zString))"
	}
}

struct Vector4: Struct, LazyVector, Vector {
	static let componentPaths = [\Vector4.w, \.x, \.y, \.z]
	var w, x, y, z: F
}

struct Ray<V: Vector> {
	var origin: V
	var direction: V {
		didSet {
			direction = direction.normalized
		}
	}
	
	init(origin: V, direction: V) {
		self.origin = origin
		self.direction = direction.normalized
	}
	
	subscript(t: V.Component) -> V {
		return origin + t * direction
	}
}
