{
	"patcher" : 	{
		"fileversion" : 1,
		"appversion" : 		{
			"major" : 8,
			"minor" : 5,
			"revision" : 2,
			"architecture" : "x64",
			"modernui" : 1
		}
,
		"classnamespace" : "box",
		"rect" : [ 59.0, 119.0, 1053.0, 745.0 ],
		"bglocked" : 0,
		"openinpresentation" : 0,
		"default_fontsize" : 12.0,
		"default_fontface" : 0,
		"default_fontname" : "Arial",
		"gridonopen" : 1,
		"gridsize" : [ 15.0, 15.0 ],
		"gridsnaponopen" : 1,
		"objectsnaponopen" : 1,
		"statusbarvisible" : 2,
		"toolbarvisible" : 1,
		"lefttoolbarpinned" : 0,
		"toptoolbarpinned" : 0,
		"righttoolbarpinned" : 0,
		"bottomtoolbarpinned" : 0,
		"toolbars_unpinned_last_save" : 0,
		"tallnewobj" : 0,
		"boxanimatetime" : 200,
		"enablehscroll" : 1,
		"enablevscroll" : 1,
		"devicewidth" : 0.0,
		"description" : "",
		"digest" : "",
		"tags" : "",
		"style" : "",
		"subpatcher_template" : "",
		"assistshowspatchername" : 0,
		"boxes" : [ 			{
				"box" : 				{
					"id" : "obj-41",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 737.0, 95.5, 80.0, 22.0 ],
					"text" : "loadmess 0.5"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-38",
					"maxclass" : "newobj",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "float" ],
					"patching_rect" : [ 750.0, 285.5, 29.5, 22.0 ],
					"text" : "* 8."
				}

			}
, 			{
				"box" : 				{
					"floatoutput" : 1,
					"id" : "obj-39",
					"maxclass" : "slider",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"parameter_enable" : 0,
					"patching_rect" : [ 750.0, 127.5, 20.0, 140.0 ],
					"size" : 1.0
				}

			}
, 			{
				"box" : 				{
					"attr" : "focalDist",
					"id" : "obj-40",
					"maxclass" : "attrui",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"parameter_enable" : 0,
					"patching_rect" : [ 750.0, 314.0, 150.0, 22.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-37",
					"maxclass" : "button",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "bang" ],
					"parameter_enable" : 0,
					"patching_rect" : [ 79.0, 272.0, 24.0, 24.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-35",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 585.0, 103.5, 87.0, 22.0 ],
					"text" : "loadmess 0.15"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-34",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 876.0, 95.5, 70.0, 22.0 ],
					"text" : "loadmess 0"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-31",
					"maxclass" : "newobj",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "float" ],
					"patching_rect" : [ 876.0, 285.5, 33.0, 22.0 ],
					"text" : "* 0.3"
				}

			}
, 			{
				"box" : 				{
					"floatoutput" : 1,
					"id" : "obj-32",
					"maxclass" : "slider",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"parameter_enable" : 0,
					"patching_rect" : [ 876.0, 127.5, 20.0, 140.0 ],
					"size" : 1.0
				}

			}
, 			{
				"box" : 				{
					"attr" : "confusion",
					"id" : "obj-33",
					"maxclass" : "attrui",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"parameter_enable" : 0,
					"patching_rect" : [ 876.0, 314.0, 150.0, 22.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-30",
					"maxclass" : "newobj",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "float" ],
					"patching_rect" : [ 594.0, 285.5, 33.0, 22.0 ],
					"text" : "* 0.2"
				}

			}
, 			{
				"box" : 				{
					"floatoutput" : 1,
					"id" : "obj-29",
					"maxclass" : "slider",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"parameter_enable" : 0,
					"patching_rect" : [ 594.0, 127.5, 20.0, 140.0 ],
					"size" : 1.0
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-24",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 389.5, 54.0, 29.5, 22.0 ],
					"text" : "16"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-22",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 356.5, 54.0, 29.5, 22.0 ],
					"text" : "12"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-12",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 322.5, 54.0, 29.5, 22.0 ],
					"text" : "10"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-4",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 576.5, 51.0, 65.0, 22.0 ],
					"text" : "1920 1080"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-28",
					"maxclass" : "newobj",
					"numinlets" : 0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 25.5, 357.0, 35.0, 22.0 ],
					"text" : "r dim"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-27",
					"maxclass" : "newobj",
					"numinlets" : 0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 167.5, 238.0, 35.0, 22.0 ],
					"text" : "r dim"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-26",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 461.5, 82.0, 37.0, 22.0 ],
					"text" : "s dim"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-23",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 25.5, 391.0, 77.0, 22.0 ],
					"text" : "prepend size"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-21",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 285.5, 54.0, 29.5, 22.0 ],
					"text" : "8"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-19",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 250.5, 54.0, 29.5, 22.0 ],
					"text" : "7"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-18",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 217.25, 54.0, 29.5, 22.0 ],
					"text" : "6"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-17",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 181.25, 54.0, 29.5, 22.0 ],
					"text" : "5"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-16",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 145.25, 54.0, 29.5, 22.0 ],
					"text" : "4"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-15",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 108.25, 54.0, 29.5, 22.0 ],
					"text" : "3"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-14",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 72.25, 54.0, 29.5, 22.0 ],
					"text" : "2"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-13",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 36.0, 54.0, 29.5, 22.0 ],
					"text" : "1"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-9",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 515.5, 51.0, 59.0, 22.0 ],
					"text" : "1280 720"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-7",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 167.5, 271.0, 75.0, 22.0 ],
					"text" : "prepend dim"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-5",
					"maxclass" : "message",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 461.5, 51.0, 52.0, 22.0 ],
					"text" : "640 360"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-11",
					"maxclass" : "newobj",
					"numinlets" : 0,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 108.0, 271.0, 43.0, 22.0 ],
					"text" : "r bang"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-10",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 0,
					"patching_rect" : [ 317.5, 460.0, 45.0, 22.0 ],
					"text" : "s bang"
				}

			}
, 			{
				"box" : 				{
					"fontface" : 0,
					"fontname" : "Arial",
					"fontsize" : 12.0,
					"id" : "obj-1",
					"maxclass" : "jit.fpsgui",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "", "" ],
					"patching_rect" : [ 370.0, 460.0, 80.0, 35.0 ]
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-6",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "jit_gl_texture", "" ],
					"patching_rect" : [ 108.0, 314.0, 446.0, 22.0 ],
					"text" : "jit.gl.texture @adapt 0 @type float32 @dim 640 360 @thru 0 @defaultimage black"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-3",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 3,
					"outlettype" : [ "jit_matrix", "bang", "" ],
					"patching_rect" : [ 108.0, 425.0, 438.0, 22.0 ],
					"text" : "jit.world @floating 1 @fps 25 @displaylink 0 @sync 0 @enable 1 @size 640 360"
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-2",
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "jit_gl_texture", "" ],
					"patcher" : 					{
						"fileversion" : 1,
						"appversion" : 						{
							"major" : 8,
							"minor" : 5,
							"revision" : 2,
							"architecture" : "x64",
							"modernui" : 1
						}
,
						"classnamespace" : "jit.gen",
						"rect" : [ 72.0, 314.0, 1095.0, 761.0 ],
						"bglocked" : 0,
						"openinpresentation" : 0,
						"default_fontsize" : 12.0,
						"default_fontface" : 0,
						"default_fontname" : "Arial",
						"gridonopen" : 1,
						"gridsize" : [ 15.0, 15.0 ],
						"gridsnaponopen" : 1,
						"objectsnaponopen" : 1,
						"statusbarvisible" : 2,
						"toolbarvisible" : 1,
						"lefttoolbarpinned" : 0,
						"toptoolbarpinned" : 0,
						"righttoolbarpinned" : 0,
						"bottomtoolbarpinned" : 0,
						"toolbars_unpinned_last_save" : 0,
						"tallnewobj" : 0,
						"boxanimatetime" : 200,
						"enablehscroll" : 1,
						"enablevscroll" : 1,
						"devicewidth" : 0.0,
						"description" : "",
						"digest" : "",
						"tags" : "",
						"style" : "",
						"subpatcher_template" : "",
						"assistshowspatchername" : 0,
						"boxes" : [ 							{
								"box" : 								{
									"id" : "obj-1",
									"maxclass" : "newobj",
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"patching_rect" : [ 35.0, 16.0, 28.0, 22.0 ],
									"text" : "in 1"
								}

							}
, 							{
								"box" : 								{
									"code" : "gold_noise(xy, seed) {\treturn fract(tan(length(xy*1.61803398874989484820459 - xy)*seed)*xy.x); }\r\nopRepLim(p, c, l){ return p-c*clamp(floor(p/c + 0.5),-l,l); }\r\n\r\nsmin(a, b, k)\n{\n    h = max( k-abs(a-b), 0.0 )/k;\n    return min( a, b ) - h*h*k*(1.0/4.0);\n}\r\n\r\nrotate2D(p, c, s) { return vec( dot(vec(c, s), p), dot(vec(-s, c), p)); }\r\nSDFsphere(p, c, ra) { return length(p - c) - ra; }\r\nSDFplane(p, h){ return p.y + h; }\r\nSDFcircle(p, r) { return length(p) - r; }\r\n\t\r\nSDFbox( p, b ){\n    d = abs(p)-b;\n    return length(max(d,0.0)) + min(max(d.x,d.y),0.0);\n}\r\n\t\r\nSDFbox3D(p, b)\n{\n  q = abs(p) - b;\n  return length(max(q,0.0)) + min(max(q.x,max(q.y,q.z)),0.0);\n}\r\n\r\nSDFpie( p, c, r )\n{\n    q = vec(abs(p.x), p.y);\n    l = length(q) - r;\n    m = length(q-c*clamp(dot(q,c),0.0,r)); // c=sin/cos of aperture\n    return max(l,m*sign(c.y*q.x-c.x*q.y));\n}\r\n\nextrude( p, dist2D, h )\n{\n    w = vec( dist2D, abs(p.z) - h );\n    return min(max(w.x,w.y),0.0) + length(max(w,0.0));\n}\r\n\r\nget2DLogo(p)\r\n{\r\n\tc = vec(0.7071067812, 0.7071067812);//cos(halfpi*0.5);\r\n\t\r\n\td0 = SDFpie(rotate2D(p, 0.7071067812, -0.7071067812), c, 0.5);\r\n\td1 = SDFpie(rotate2D(p - vec(0.5, 0.), -0.7071067812, 0.7071067812) , c, 0.5);\r\n\td2 = SDFpie(rotate2D(p - vec(1., 0.5), -0.7071067812, 0.7071067812) , c, 0.5);\r\n\td3 = SDFpie(rotate2D(p - vec(1., 0.), 0.7071067812, -0.7071067812) , c, 0.5);\r\n\td4 = SDFbox(p - vec(1.25, -0.33), vec(0.25, 0.17));\r\n\td5 = SDFpie(rotate2D(p - vec(1., -0.5), -0.7071067812, -0.7071067812) , c, 0.5);\r\n\td6 = SDFbox(p - vec(2, -0.2), vec(0.25, 0.20));\r\n\td7 = SDFpie(rotate2D(p - vec(1.75, -0.), 0.7071067812, -0.7071067812) , c, 0.5);\r\n\td8 = SDFbox(p - vec(2.75, -0.25), vec(0.25, 0.25));\r\n\td9 = SDFpie(rotate2D(p - vec(2.5, -0.5), -0.7071067812, -0.7071067812) , c, 0.5);\r\n\td10 = SDFpie(rotate2D(p - vec(3, 0.),0.7071067812, 0.7071067812) , c, 0.5);\r\n\t\r\n\td = d0;\r\n\td = min(d, d1);\r\n\td = min(d, d2);\r\n\td = min(d, d3);\r\n\td = min(d, d4);\r\n\td = min(d, d5);\r\n\td = min(d, d6);\r\n\td = min(d, d7);\r\n\td = min(d, d8);\r\n\td = min(d, d9);\r\n\td = min(d, d10);\r\n\treturn d;\r\n}\r\n\r\ngetLogo(p, randTime, distort)\r\n{\r\n\r\n\td = extrude(p, get2DLogo(p.xy), 0.1);\r\n\t\r\n\tk = p - vec(1.5, 0., 0.);\r\n\tc = vec(0.5, 0.5, 0.5);\r\n\tl = vec(4., 0., 4.);\r\n\tw = opRepLim(k, c, l);\r\n\tid = floor( k.xz / c.xz + vec(0.5, 0.5) );\r\n\trandh = fract(id.x * 1.61803398874989484820459 + id.y * 1.61803398874989484820459 * vec(2, 3));\r\n\trandh = sin(fract(randh + randTime*0.09*randh)*twopi)*0.5 + 0.5;\r\n\tt = vec(w.x, -abs(p.y) + 3.3 - randh*0.2, w.z);\r\n\td1 = SDFbox3D(t, vec(0.18, 2, 0.18));\r\n\t\r\n\td2 = SDFsphere(p, vec( sin(randTime*0.03), sin(randTime*0.13*0.4), cos(randTime*0.234*0.1)), 0.2);\r\n\td3 = SDFsphere(p - vec(3, 0., 0.), vec( sin(randTime*0.04), sin(randTime*0.13*0.12), cos(randTime*0.134*0.03)), 0.2);\r\n\td4 = SDFsphere(p - vec(1.5, 0., 0.), vec( sin(randTime*0.15), sin(randTime*0.12*0.72), cos(randTime*0.23*0.13)), 0.2);\r\n\r\n\r\n\td = min(d, d1);\r\n\td = smin(d, d2, 0.5);\r\n\td = smin(d, d3, 0.5);\r\n\td = smin(d, d4, 0.5);\r\n\t\r\n\troundness = distort > 0. ? gold_noise( vec(atan2(p.x-1.5, p.y), atan2(p.z, p.y))*0.003, 1800)*distort : 0.;\r\n\t//roundness = distort > 0. ? fbm( vec(p.x + p.z, p.y)*0.002, 1, randTime)*distort : 0.;\r\n\treturn d - 0.04 - roundness;\r\n}\r\n\t\r\ngetDist(p, randTime, distort)\r\n{\r\n\tq = opRepLim(p, vec(6, 6, 6), vec(3., 3., 3.));//{ return p-c*clamp(floor(p/c + 0.5),-l,l); }\r\n\treturn getLogo(q + vec(1.5, 0., 0.), randTime, distort);\r\n}\r\n\r\nmap(ro, rd, randTime, distort, randStep)\r\n{\r\n\tminDist = 0.01;\r\n\tmaxDist = 10.;\r\n\tp = ro + rd*minDist;\r\n\tdist = 0.0;\r\n\tcurrDist = minDist;\r\n\tmaxSteps = 40;\r\n\t\r\n\tfor(i = 0; i < maxSteps; i += 1){\r\n\t\tdist = getDist(p, randTime, distort);\r\n\r\n\t\tif(abs(dist) < minDist || currDist > maxDist) {break; }\r\n\t\tcurrDist += dist;\r\n\t\tp += rd * dist;\r\n\t}\r\n\treturn currDist;\r\n}\r\n\r\nmapRef(ro, rd, randTime, distort)\r\n{\r\n\tminDist = 0.01;\r\n\tmaxDist = 10.;\r\n\tp = ro + rd*minDist;\r\n\tdist = 0.0;\r\n\tcurrDist = minDist;\r\n\tmaxSteps = 30;\r\n\tfor(i = 0; i < maxSteps; i += 1){\r\n\t\tdist = getDist(p, randTime, distort);\r\n\r\n\t\tif(dist < minDist || currDist > maxDist) {break; }\r\n\t\tcurrDist += dist;\r\n\t\tp += rd*dist;\r\n\t}\r\n\treturn currDist;\r\n}\r\n\r\ngetNorm(p, randTime, distort) // for function f(p)\n{\n    h = 0.00001; // replace by an appropriate value\n    k = vec(1.,-1.,0.);\n    return normalize( k.xyy*getDist( p + k.xyy*h, randTime, distort ) + \n                      k.yyx*getDist( p + k.yyx*h, randTime, distort ) + \n                      k.yxy*getDist( p + k.yxy*h, randTime, distort ) + \n                      k.xxx*getDist( p + k.xxx*h, randTime, distort ) );\n}\r\n\r\ngetShadow( ro, rd, k, randTime, distort)\n{\n    res = 1.0;\r\n\tt = 0.1;\n    while( t < 6)\n    {\n        h = getDist(ro + rd*t, randTime, distort);\n        if( h < 0.001 ){\r\n\t\t\tres = 0.;\r\n\t\t\tbreak;\r\n\t\t}\n\n        res = min( res, k*h/t );\n        t += h*1;\n    }\n    return res;//clamp(res, 0., 1.);\n}\r\n\r\n\r\ngetAO( pos, nor, randTime, distort )\n{\n\tocc = 0.0;\n    sca = 1.0;\n    for( i=0; i<4; i += 1 )\n    {\n        hr = 0.01 + 0.3*float(i)*0.25;\n        aopos =  nor * hr + pos;\n        dd = getDist( aopos, randTime, distort );\n        occ += (hr - dd)*sca;\n        sca *= 0.95;\n    }\n    return clamp( 1.0 - 1.0*occ, 0.0, 1.0 );    \n}\r\n\r\ngetSpe(R, ligDir)\r\n{\r\n\tspe = max(0., dot(R, ligDir));\r\n\tspe *= spe; //^2\r\n\tspe *= spe; //^4\r\n\tspe *= spe; //^8\r\n\treturn spe * spe * spe; //^24\r\n}\r\n\r\nhalton (s)\n{\n  a = vec(1,1,0,0);\n  while (s.x > 0. && s.y > 0.)\n  {\n    a /= vec(2, 3, 1, 1);\n    a += vec(0., 0., a.x*(s.x%2.), a.y*(s.y% 3.));\n    s = floor(s/vec(2, 3));\n  }\n  return a.zw;\n}\r\n\r\nParam samplesPerFrame(2.);\r\nParam aperture(0.03);\r\nParam focalDist(4.);\r\nParam confusion(0.);\r\n\r\ntime = in1.a * 100000.;\r\ncol = vec(0., 0., 0.);\r\nres = vec(0., 0., 0.);\r\n\r\nif(abs(snorm.y) > 0.8){ //create matte\r\n\tres = col;\r\n\t} else {\r\n\r\n\tdiscPortion = (twopi / samplesPerFrame);\r\n\tstepLen = 1. / samplesPerFrame;\r\n\tcell = norm*dim; \r\n\tseed = gold_noise(cell, 0.2 + fract(time*0.0321));\r\n\t\r\n\tfor(i = 0; i < samplesPerFrame; i += 1){\r\n\t\trandStep = fract( float(i)*1.61803398874989484820459 + seed );//float(i)*stepLen + stepLen*gold_noise(cell, 0.2 + fract(time*0.0321 + float(i)*1.61803398874989484820459));\r\n\r\n\t\trandTime = mix(time, time - 1., randStep);\r\n\r\n\t\tzoom = sin(randTime*0.023)*2;\r\n\t\tzoom = clip(zoom, -0.5, 0.5);\r\n\t\tzoom += 0.5;\r\n\t\tzoom = smoothstep(0., 1., zoom);\r\n\t\tzoom = smoothstep(0., 1., zoom)*2;\r\n\t\tzoom += 0.85;\r\n\r\n     \t// camera movement\t\n\t\tan = 0.035*randTime;\n\t\tro = zoom*vec( 4*cos(an), cos(an*0.765)*0.1+sin(randTime*0.6)*(zoom-0.85)*0.05, 4*sin(an) );\r\n\t\tta = vec( 0.0, 0.0, 0.0 ) + vec((cos(randTime*0.1)-1)*7*(zoom-0.7), sin(randTime*0.12)*0.5, cos(randTime*0.032)*0.1);\r\n\t\t\t\t\n    \t// camera matrix\n\t\tww = normalize( ta - ro );\n\t\tuu = normalize( cross(ww,vec(0.0,1.0,0.0) ) );\n\t\tvv = normalize( cross(uu,ww));\r\n\t\t\n\t\t// create view ray\r\n\t\taspectRatio = dim.x / dim.y;\r\n\t\tcenterDist = length(snorm*vec(aspectRatio, 1.));\r\n\t\tsnormAngle = atan2(snorm.y,snorm.x*aspectRatio);\r\n\t\tsnormAngle += sin(randTime*0.3)*0.05*(zoom-0.7);\r\n\t\tcartSnorm = vec(cos(snormAngle), sin(snormAngle))*centerDist;\r\n\t\t\t\t\n\t\trd = normalize( cartSnorm.x*uu + -cartSnorm.y*vv + 2.0*ww );\r\n\t\t\r\n\t\trandOffset = vec( \tgold_noise(cell, 0.2 + fract(randTime*0.001)),\r\n\t\t\t\t\t\t\tgold_noise(cell, 0.2 + fract(randTime*0.001*1.61803398874989484820459)),\r\n\t\t\t\t\t\t\t0.\r\n\t\t\t\t\t\t);\r\n\r\n\t\tbokehAngle = randOffset.x*discPortion + float(i)*discPortion;\r\n\t\tbokehDist = sqrt(randOffset.y) * aperture;\r\n\t\trandOffset = vec( cos(bokehAngle)*bokehDist, sin(bokehAngle)*bokehDist, 0.);\r\n\t\trandOffset = randOffset.x*uu + randOffset.y*vv + randOffset.z*ww;\r\n\t\tfocalPoint = ro + rd*focalDist;\r\n\t\tro += randOffset;\r\n\t\trd = normalize(focalPoint - ro);\r\n\r\n\t\tligDir0 = normalize(vec(1., 0.5, 1));\r\n\t\tligCol0 = vec(4., 2., 1.)*2;\r\n\t\tligDir1 = normalize(vec(-1., -0.5, -3));\r\n\t\tligCol1 = vec(1., 2., 4.)*2;\t\t\r\n\t\t\r\n\t\t//get the distance\r\n\t\tdist = map(ro, rd, randTime, confusion, randStep);\r\n\t\t\r\n\t\tvignette = smoothstep(0.8, 0., 0.4*length( vec(snorm.x*aspectRatio, snorm.y)));\r\n\t\tbgCol = vec(0.03, 0.03, 0.03)*vignette;\r\n\t\t\r\n\t\tflare = max(0., dot(rd, ligDir0));\r\n\t\tflare2 = flare * flare;//^2\r\n\t\tflare2 *= flare2;//*4\r\n\t\tflare *= flare2;//^5\r\n\t\tbgCol += flare * ligCol0*0.1; //add lens flare\r\n\t\t\r\n\t\tflare = max(0., dot(rd, ligDir1));\r\n\t\tflare2 = flare * flare; //^2\r\n\t\tflare2 *= flare2;//^4\r\n\t\tflare *= flare2;//^5\r\n\t\tbgCol += flare * ligCol1*0.1; //add lens flare\t\t\r\n\r\n\t\tcol = bgCol;\r\n\t\tmaxDist = 10.;\r\n\t\r\n\t\tif(dist < maxDist) { \r\n\t\t\thitPos = ro + rd*dist;\r\n\t\t\tnor = getNorm(hitPos, randTime, confusion);\r\n\r\n\t\t\trandVec = vec(0., 0., 0.);\r\n\t\t\tR = reflect(rd, nor);\r\n\r\n\t\t\talb = vec(1., 1., 1.);\r\n\t\t\tif(abs(hitPos.y) > 1.1){\r\n\t\t\t\tpattern = floor(hitPos.x + 0.25);\r\n\t\t\t\tpattern += floor(hitPos.z + 0.25);\r\n\t\t\t\tpattern = pattern % 2;\r\n\t\t\t\t//pattern = mix(0.2, 1., pattern);\r\n\t\t\t\talb = mix(vec(1., 0.6, 0.6), vec(1., 1., 1.), pattern);\r\n\t\t\t\t//alb *= pattern;\r\n\t\t\t\trandVec = vec( \tgold_noise(cell, 0.1 + fract(randTime*0.001)),\r\n\t\t\t\t\t\t\t\tgold_noise(cell, 0.2 + fract(randTime*0.001)),\r\n\t\t\t\t\t\t\t\tgold_noise(cell, 0.3 + fract(randTime*0.001))\r\n\t\t\t\t\t\t\t);\r\n\t\t\t\trandVec *= 2.;\r\n\t\t\t\trandVec -= vec(1., 1., 1);\r\n\t\t\t\trandVec *= pattern*0.1;\r\n\t\t\t} \r\n\t\t\t\r\n\t\t\tR = normalize(R + randVec);\r\n\t\t\tfre = 1. - max(0., dot(-rd, nor));\r\n\t\t\tfre2 = fre * fre;//*2\r\n\t\t\tfre2 *= fre2;//^4\r\n\t\t\tfre *= fre2;//^5\r\n\t\t\t\r\n\t\t\tkS = 0.5 + fre*0.5;\r\n\t\t\tkD = 1. - kS;\r\n\t\t\tcol = vec(0., 0., 0.);\r\n\t\r\n\t\t\tvisible = mapRef(hitPos, R, randTime) >= maxDist;\r\n\t\t\r\n\t\t\t//light 0\r\n\t\t\tdif = max(0., dot(nor, ligDir0));\r\n\t\t\tsha = getShadow(hitPos, ligDir0, 25., randTime, confusion);\r\n\t\t\tspe = visible ? getSpe(R, ligDir0) : 0.;\r\n\t\t\tcol += (dif*kD*sha + spe*kS)*ligCol0;\r\n\r\n\t\t\t//light 1\r\n\t\t\tdif = max(0., dot(nor, ligDir1));\r\n\t\t\tsha = getShadow(hitPos, ligDir1, 25., randTime, confusion);\r\n\t\t\tspe = visible ? getSpe(R, ligDir1) : 0.;\r\n\t\t\tcol += (dif*kD*sha + spe*kS)*ligCol1;\r\n\r\n\t\t\t//ambient light\r\n\t\t\tcol += vec(0.7, 0.7, 0.7)*getAO(hitPos, nor, randTime, confusion);\r\n\t\t\tcol *= alb;\r\n\r\n\t\t}\r\n\r\n\t\tcol = mix(col, bgCol, min(dist/maxDist, 1.)); //add fog\t\r\n\t\tres += col;\r\n\t}\r\n\tres /= float(samplesPerFrame); //compute the mean\r\n\t\r\n\tres /= res + vec(1., 1., 1.); //tonemapping\r\n\tres += seed*0.008; //add film grain\r\n\tres = pow(res, vec(0.4545454545, 0.4545454545, 0.4545454545)); //gamma correction\r\n\r\n}\r\ntime += 1.;\r\ntime *= 0.00001;\r\ntime = fract(time);\r\nout1 = vec(res.r, res.g, res.b, time);",
									"fontface" : 0,
									"fontname" : "<Monospaced>",
									"fontsize" : 12.0,
									"id" : "obj-5",
									"maxclass" : "codebox",
									"numinlets" : 1,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"patching_rect" : [ 35.0, 50.0, 972.0, 681.0 ]
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-4",
									"maxclass" : "newobj",
									"numinlets" : 1,
									"numoutlets" : 0,
									"patching_rect" : [ 35.0, 747.0, 35.0, 22.0 ],
									"text" : "out 1"
								}

							}
 ],
						"lines" : [ 							{
								"patchline" : 								{
									"destination" : [ "obj-5", 0 ],
									"source" : [ "obj-1", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-4", 0 ],
									"source" : [ "obj-5", 0 ]
								}

							}
 ]
					}
,
					"patching_rect" : [ 108.0, 348.0, 172.0, 22.0 ],
					"text" : "jit.gl.pix @samplesPerFrame 3"
				}

			}
, 			{
				"box" : 				{
					"attr" : "samplesPerFrame",
					"id" : "obj-20",
					"maxclass" : "attrui",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"parameter_enable" : 0,
					"patching_rect" : [ 36.0, 97.0, 150.0, 22.0 ]
				}

			}
, 			{
				"box" : 				{
					"attr" : "enable",
					"id" : "obj-8",
					"maxclass" : "attrui",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"parameter_enable" : 0,
					"patching_rect" : [ 130.0, 391.0, 150.0, 22.0 ]
				}

			}
, 			{
				"box" : 				{
					"attr" : "aperture",
					"id" : "obj-25",
					"maxclass" : "attrui",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"parameter_enable" : 0,
					"patching_rect" : [ 594.0, 314.0, 150.0, 22.0 ]
				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"destination" : [ "obj-6", 0 ],
					"source" : [ "obj-11", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-20", 0 ],
					"source" : [ "obj-12", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-20", 0 ],
					"source" : [ "obj-13", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-20", 0 ],
					"source" : [ "obj-14", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-20", 0 ],
					"source" : [ "obj-15", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-20", 0 ],
					"source" : [ "obj-16", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-20", 0 ],
					"source" : [ "obj-17", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-20", 0 ],
					"source" : [ "obj-18", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-20", 0 ],
					"source" : [ "obj-19", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 0 ],
					"order" : 0,
					"source" : [ "obj-2", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-6", 0 ],
					"midpoints" : [ 117.5, 383.0, 94.5, 383.0, 94.5, 303.0, 117.5, 303.0 ],
					"order" : 1,
					"source" : [ "obj-2", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-2", 0 ],
					"source" : [ "obj-20", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-20", 0 ],
					"source" : [ "obj-21", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-20", 0 ],
					"source" : [ "obj-22", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 0 ],
					"source" : [ "obj-23", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-20", 0 ],
					"source" : [ "obj-24", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-2", 0 ],
					"source" : [ "obj-25", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-7", 0 ],
					"source" : [ "obj-27", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-23", 0 ],
					"source" : [ "obj-28", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-30", 0 ],
					"source" : [ "obj-29", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-1", 0 ],
					"order" : 0,
					"source" : [ "obj-3", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-10", 0 ],
					"order" : 1,
					"source" : [ "obj-3", 1 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-25", 0 ],
					"source" : [ "obj-30", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-33", 0 ],
					"source" : [ "obj-31", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-31", 0 ],
					"source" : [ "obj-32", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-2", 0 ],
					"source" : [ "obj-33", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-32", 0 ],
					"source" : [ "obj-34", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-29", 0 ],
					"source" : [ "obj-35", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 0 ],
					"source" : [ "obj-37", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-40", 0 ],
					"source" : [ "obj-38", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-38", 0 ],
					"source" : [ "obj-39", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-26", 0 ],
					"source" : [ "obj-4", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-2", 0 ],
					"source" : [ "obj-40", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-39", 0 ],
					"source" : [ "obj-41", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-26", 0 ],
					"source" : [ "obj-5", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-2", 0 ],
					"source" : [ "obj-6", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-6", 0 ],
					"source" : [ "obj-7", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-3", 0 ],
					"source" : [ "obj-8", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-26", 0 ],
					"source" : [ "obj-9", 0 ]
				}

			}
 ],
		"dependency_cache" : [  ],
		"autosave" : 0
	}

}
