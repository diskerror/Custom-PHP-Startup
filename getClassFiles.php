#!/usr/bin/php
<?php

set_error_handler( function ($errno, $errstr, $errfile, $errline) {
	throw new ErrorException($errstr, $errno, 0, $errfile, $errline);
} );

//	Use this for uncaught exceptions so we can see all the useful details.
set_exception_handler( function (\Exception $e) {
	while ( ob_get_level() ) {
		ob_end_flush();
	}

	fwrite(STDERR, PHP_EOL . $e . PHP_EOL);
	exit($e->getCode());
} );


////////////////////////////////////////////////////////////////////////////////
if( count($argv) === 1 ) {
	fwrite(STDERR, 'Type the command plus one or more paths to check.' . PHP_EOL);
	fwrite(STDERR, $argv[0] . ' <path>[ <path>[ ...]]' . PHP_EOL);
	exit(1);
}

//	Drop application name.
array_shift($argv);


if ( !defined('T_TRAIT') ) {
	define('T_TRAIT', -1);
}

//	get include paths, except "."
$paths = explode(PATH_SEPARATOR, get_include_path());
foreach ( $paths as &$p ) {
	if ( $p === '.' ) {
		unset($p);
		break;
	}
}

$class2File = [];

foreach ( $argv as $path ) {
	$realPath = realpath($path);
	if ( !is_dir($realPath) ) {
		fwrite(STDERR, 'The path "' . $path . '" does not exist.' . PHP_EOL);
		continue;
	}

	fwrite(STDOUT, 'Loading from "' . $path . '".' . PHP_EOL);

	$iter = new RecursiveIteratorIterator(
		new RecursiveDirectoryIterator($realPath, RecursiveDirectoryIterator::SKIP_DOTS)
	);

	foreach ($iter as $f) {
		//	Only process files with the 'php' extension AND
		//		only if they are NOT in a PhpUnit nor a /Tests/ path (case insensitive).
		if (
			strcasecmp(pathinfo($f, PATHINFO_EXTENSION), 'php') !== 0 ||
			stripos($f->__toString(), 'phpunit') !== false ||
			stripos($f->__toString(), '/Tests/') !== false
		) {
			continue;
		}

		$tokens = token_get_all( file_get_contents($f) );

		//	Reset namespace for each file whether it's used in a file or not.
		$namespace = '';
		$count = count($tokens);
		for ($i = 0; $i < $count; ++$i) {
			if (!is_array($tokens[$i])) {
				continue;
			}

			switch ($tokens[$i][0]) {
				case T_NAMESPACE:
				$namespace = ''; //	new namespace is started.
				while ( $tokens[$i][0]!==T_STRING && $tokens[$i][0]!==T_NS_SEPARATOR ) {
					++$i;	//	skip next token («whitespace», «comment», «;»)
				}

				for (; $i < $count && ($tokens[$i][0]===T_STRING||$tokens[$i][0]===T_NS_SEPARATOR); ++$i) {
					$namespace .= $tokens[$i][1];
				}

				$namespace .= '\\';
				break;

				case T_TRAIT:
				case T_CLASS:
				// ignore T_CLASS after T_DOUBLE_COLON to allow PHP >=5.5 FQCN scalar resolution
				if ($i > 0 && is_array($tokens[$i-1]) && $tokens[$i-1][0] === T_DOUBLE_COLON) {
					break;
				}
				case T_INTERFACE:
				// Abstract class, class, interface or trait found
				if ( strpos($namespace, 'Composer') !== 0 ) {
					for ($i++; $i < $count; $i++) {
						//	get only the next string, and it does not start with 	v
						if (
							T_STRING === $tokens[$i][0] &&
							strpos($tokens[$i][1], 'Composer') !== 0 &&
							strpos($tokens[$i][1], 'stdClass') !== 0
						) {
							$class2File[ $namespace . $tokens[$i][1] ] = $f->__toString();
							break;
						}
					}
				}
				break;

				default:
				break;
			}
		}
	}
}

ksort($class2File, SORT_STRING);
// uksort($class2File, function($a, $b){
// 	$i = strlen($a);
// 	$j = strlen($b);
// 	while ( $i && $j ) {
// 		$i--; $j--;
// 		if ($a[$i] > $b[$j])
// 			return 1;
// 		if ($a[$i] < $b[$j])
// 			return -1;
// 	}
// 	if ( $i )
// 		return 1;
// 	if ( $j )
// 		return -1;
// 	return 0;
// });

// var_export($class2File);

//	Write output to a C++ text file.
$fp = fopen('AutoloadValues.cp', 'w');

fwrite($fp, '
//	This file was generated by getClassFiles.php.

#include "Autoload.h"

const autoloadMap Autoload::_val = {
');

foreach ( $class2File as $c=>$p ) {
	fwrite( $fp, sprintf("\t{\"%s\", \"%s\"},\n", addslashes($c), $p) );
}

//	remove last comma
fseek($fp, -2, SEEK_END);

fwrite($fp, "\n};\n");
fwrite($fp, 'const size_t Autoload::phpMembers = ' . count($class2File) . ";\n");
fwrite($fp, 'const std::string Autoload::phpMembersStr = "' . count($class2File) . "\";\n");
fclose($fp);

// fwrite(STDOUT, PHP_EOL);
