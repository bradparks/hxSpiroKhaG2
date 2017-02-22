package;

import kha.System;

class Main {
	public static function main() {
		System.init({title: "Empty", width: 1024, height: 1024, samplesPerPixel: 4}, function() {
			new Empty();
		});
	}
}
