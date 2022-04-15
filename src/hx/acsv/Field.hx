package acsv;

/**
 * 1. Copyright (c) 2022 amin2312
 * 2. Version 1.0.0
 * 3. MIT License
 *
 * CSV head field.
 */
 @:expose
class Field {
	/**
	 * Full Name.
	 */
	public var fullName:String;
	/**
	 * Name.
	 */
	public var name:String;
	/**
	 * Type.
	 */
	public var type:String;
	/**
	 * Constructor.
	 */
	@:dox(hide)
	public function new() {}
}
