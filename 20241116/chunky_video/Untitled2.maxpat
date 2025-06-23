{
	"patcher" : 	{
		"fileversion" : 1,
		"appversion" : 		{
			"major" : 8,
			"minor" : 6,
			"revision" : 5,
			"architecture" : "x64",
			"modernui" : 1
		}
,
		"classnamespace" : "box",
		"rect" : [ 34.0, 100.0, 1444.0, 774.0 ],
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
					"bgmode" : 1,
					"border" : 1,
					"clickthrough" : 0,
					"enablehscroll" : 0,
					"enablevscroll" : 0,
					"id" : "obj-7",
					"lockeddragscroll" : 0,
					"lockedsize" : 0,
					"maxclass" : "bpatcher",
					"name" : "vs_sources_main.maxpat",
					"numinlets" : 1,
					"numoutlets" : 1,
					"offset" : [ 0.0, 0.0 ],
					"outlettype" : [ "jit_gl_texture" ],
					"patching_rect" : [ 385.0, 69.0, 296.400000870227814, 125.5 ],
					"viewvisibility" : 1
				}

			}
, 			{
				"box" : 				{
					"id" : "obj-18",
					"maxclass" : "newobj",
					"numinlets" : 2,
					"numoutlets" : 1,
					"outlettype" : [ "jit_gl_texture" ],
					"patcher" : 					{
						"fileversion" : 1,
						"appversion" : 						{
							"major" : 8,
							"minor" : 6,
							"revision" : 5,
							"architecture" : "x64",
							"modernui" : 1
						}
,
						"classnamespace" : "box",
						"rect" : [ 59.0, 119.0, 640.0, 480.0 ],
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
									"id" : "obj-11",
									"maxclass" : "newobj",
									"numinlets" : 1,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"patching_rect" : [ 193.5, 100.0, 89.0, 22.0 ],
									"text" : "prepend speed"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-9",
									"maxclass" : "newobj",
									"numinlets" : 1,
									"numoutlets" : 2,
									"outlettype" : [ "jit_gl_texture", "" ],
									"patching_rect" : [ 157.0, 393.0, 183.0, 22.0 ],
									"text" : "jit.gl.texture vsynth @rectangle 0"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-7",
									"maxclass" : "newobj",
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"patching_rect" : [ 50.0, 182.0, 54.0, 22.0 ],
									"text" : "r canvas"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-35",
									"maxclass" : "newobj",
									"numinlets" : 2,
									"numoutlets" : 2,
									"outlettype" : [ "jit_gl_texture", "" ],
									"patcher" : 									{
										"fileversion" : 1,
										"appversion" : 										{
											"major" : 8,
											"minor" : 6,
											"revision" : 5,
											"architecture" : "x64",
											"modernui" : 1
										}
,
										"classnamespace" : "jit.gen",
										"rect" : [ 260.0, 156.0, 657.0, 516.0 ],
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
										"boxes" : [ 											{
												"box" : 												{
													"id" : "obj-14",
													"maxclass" : "newobj",
													"numinlets" : 1,
													"numoutlets" : 1,
													"outlettype" : [ "" ],
													"patching_rect" : [ 132.0, 235.0, 124.0, 22.0 ],
													"text" : "smoothstep 0.01 0.01"
												}

											}
, 											{
												"box" : 												{
													"id" : "obj-1",
													"maxclass" : "newobj",
													"numinlets" : 1,
													"numoutlets" : 1,
													"outlettype" : [ "" ],
													"patching_rect" : [ 50.0, 315.0, 67.0, 22.0 ],
													"text" : "clamp 0. 1."
												}

											}
, 											{
												"box" : 												{
													"fontname" : "Arial",
													"fontsize" : 12.0,
													"id" : "obj-20",
													"maxclass" : "newobj",
													"numinlets" : 3,
													"numoutlets" : 1,
													"outlettype" : [ "" ],
													"patching_rect" : [ 50.0, 282.0, 101.0, 22.0 ],
													"text" : "mix"
												}

											}
, 											{
												"box" : 												{
													"fontname" : "Arial",
													"fontsize" : 12.0,
													"id" : "obj-2",
													"maxclass" : "newobj",
													"numinlets" : 0,
													"numoutlets" : 1,
													"outlettype" : [ "" ],
													"patching_rect" : [ 50.0, 189.0, 30.0, 22.0 ],
													"text" : "in 2"
												}

											}
, 											{
												"box" : 												{
													"fontname" : "Arial",
													"fontsize" : 12.0,
													"id" : "obj-9",
													"maxclass" : "newobj",
													"numinlets" : 1,
													"numoutlets" : 0,
													"patching_rect" : [ 50.0, 347.0, 37.0, 22.0 ],
													"text" : "out 1"
												}

											}
, 											{
												"box" : 												{
													"fontname" : "Arial",
													"fontsize" : 12.0,
													"id" : "obj-5",
													"maxclass" : "newobj",
													"numinlets" : 0,
													"numoutlets" : 1,
													"outlettype" : [ "" ],
													"patching_rect" : [ 91.0, 102.0, 30.0, 22.0 ],
													"text" : "in 1"
												}

											}
, 											{
												"box" : 												{
													"fontface" : 0,
													"fontname" : "Arial",
													"fontsize" : 12.0,
													"id" : "obj-7",
													"maxclass" : "newobj",
													"numinlets" : 1,
													"numoutlets" : 1,
													"outlettype" : [ "" ],
													"patching_rect" : [ 132.0, 195.0, 57.0, 22.0 ],
													"text" : "dot luma"
												}

											}
, 											{
												"box" : 												{
													"fontface" : 0,
													"fontname" : "Arial",
													"fontsize" : 12.0,
													"id" : "obj-3",
													"maxclass" : "newobj",
													"numinlets" : 0,
													"numoutlets" : 1,
													"outlettype" : [ "" ],
													"patching_rect" : [ 424.0, 24.0, 186.0, 22.0 ],
													"text" : "param luma 0.299 0.587 0.114 0."
												}

											}
 ],
										"lines" : [ 											{
												"patchline" : 												{
													"destination" : [ "obj-9", 0 ],
													"source" : [ "obj-1", 0 ]
												}

											}
, 											{
												"patchline" : 												{
													"destination" : [ "obj-20", 2 ],
													"source" : [ "obj-14", 0 ]
												}

											}
, 											{
												"patchline" : 												{
													"destination" : [ "obj-20", 0 ],
													"source" : [ "obj-2", 0 ]
												}

											}
, 											{
												"patchline" : 												{
													"destination" : [ "obj-1", 0 ],
													"source" : [ "obj-20", 0 ]
												}

											}
, 											{
												"patchline" : 												{
													"destination" : [ "obj-20", 1 ],
													"order" : 1,
													"source" : [ "obj-5", 0 ]
												}

											}
, 											{
												"patchline" : 												{
													"destination" : [ "obj-7", 0 ],
													"order" : 0,
													"source" : [ "obj-5", 0 ]
												}

											}
, 											{
												"patchline" : 												{
													"destination" : [ "obj-14", 0 ],
													"source" : [ "obj-7", 0 ]
												}

											}
 ],
										"editing_bgcolor" : [ 0.9, 0.9, 0.9, 1.0 ]
									}
,
									"patching_rect" : [ 156.0, 356.0, 164.0, 22.0 ],
									"text" : "jit.gl.pix vsynth @type float32"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-28",
									"maxclass" : "newobj",
									"numinlets" : 1,
									"numoutlets" : 2,
									"outlettype" : [ "jit_gl_texture", "" ],
									"patcher" : 									{
										"fileversion" : 1,
										"appversion" : 										{
											"major" : 8,
											"minor" : 6,
											"revision" : 5,
											"architecture" : "x64",
											"modernui" : 1
										}
,
										"classnamespace" : "jit.gen",
										"rect" : [ 59.0, 106.0, 600.0, 450.0 ],
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
										"boxes" : [ 											{
												"box" : 												{
													"id" : "obj-1",
													"maxclass" : "newobj",
													"numinlets" : 0,
													"numoutlets" : 1,
													"outlettype" : [ "" ],
													"patching_rect" : [ 176.0, 329.0, 28.0, 22.0 ],
													"text" : "in 1"
												}

											}
, 											{
												"box" : 												{
													"id" : "obj-4",
													"maxclass" : "newobj",
													"numinlets" : 1,
													"numoutlets" : 0,
													"patching_rect" : [ 176.0, 418.0, 35.0, 22.0 ],
													"text" : "out 1"
												}

											}
 ],
										"lines" : [ 											{
												"patchline" : 												{
													"destination" : [ "obj-4", 0 ],
													"source" : [ "obj-1", 0 ]
												}

											}
 ]
									}
,
									"patching_rect" : [ 266.0, 313.0, 164.0, 22.0 ],
									"text" : "jit.gl.pix vsynth @type float32"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-22",
									"maxclass" : "newobj",
									"numinlets" : 1,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"patching_rect" : [ 147.0, 205.0, 122.0, 22.0 ],
									"text" : "prepend param iTime"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-21",
									"maxclass" : "newobj",
									"numinlets" : 1,
									"numoutlets" : 2,
									"outlettype" : [ "", "" ],
									"patching_rect" : [ 147.0, 169.0, 63.0, 22.0 ],
									"text" : "jit.mo.time"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-31",
									"maxclass" : "newobj",
									"numinlets" : 1,
									"numoutlets" : 2,
									"outlettype" : [ "jit_gl_texture", "" ],
									"patching_rect" : [ 328.0, 197.0, 183.0, 22.0 ],
									"text" : "jit.gl.texture vsynth @rectangle 0"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-43",
									"maxclass" : "newobj",
									"numinlets" : 2,
									"numoutlets" : 2,
									"outlettype" : [ "jit_gl_texture", "" ],
									"patching_rect" : [ 156.0, 275.0, 219.0, 22.0 ],
									"text" : "jit.gl.slab vsynth @file chunky_video.jxs"
								}

							}
, 							{
								"box" : 								{
									"id" : "obj-15",
									"maxclass" : "newobj",
									"numinlets" : 2,
									"numoutlets" : 2,
									"outlettype" : [ "jit_gl_texture", "" ],
									"patching_rect" : [ 157.0, 444.0, 179.0, 22.0 ],
									"text" : "jit.gl.slab vsynth @file Image.jxs"
								}

							}
, 							{
								"box" : 								{
									"comment" : "",
									"id" : "obj-14",
									"index" : 1,
									"maxclass" : "inlet",
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "" ],
									"patching_rect" : [ 193.5, 40.0, 30.0, 30.0 ]
								}

							}
, 							{
								"box" : 								{
									"comment" : "",
									"id" : "obj-16",
									"index" : 2,
									"maxclass" : "inlet",
									"numinlets" : 0,
									"numoutlets" : 1,
									"outlettype" : [ "jit_gl_texture" ],
									"patching_rect" : [ 328.0, 40.0, 30.0, 30.0 ]
								}

							}
, 							{
								"box" : 								{
									"comment" : "",
									"id" : "obj-17",
									"index" : 1,
									"maxclass" : "outlet",
									"numinlets" : 1,
									"numoutlets" : 0,
									"patching_rect" : [ 157.0, 526.0, 30.0, 30.0 ]
								}

							}
 ],
						"lines" : [ 							{
								"patchline" : 								{
									"destination" : [ "obj-21", 0 ],
									"source" : [ "obj-11", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-11", 0 ],
									"source" : [ "obj-14", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-17", 0 ],
									"source" : [ "obj-15", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-31", 0 ],
									"source" : [ "obj-16", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-22", 0 ],
									"source" : [ "obj-21", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-43", 0 ],
									"source" : [ "obj-22", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-35", 1 ],
									"source" : [ "obj-28", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-43", 1 ],
									"source" : [ "obj-31", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-28", 0 ],
									"order" : 0,
									"source" : [ "obj-35", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-9", 0 ],
									"order" : 1,
									"source" : [ "obj-35", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-35", 0 ],
									"source" : [ "obj-43", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-43", 0 ],
									"source" : [ "obj-7", 0 ]
								}

							}
, 							{
								"patchline" : 								{
									"destination" : [ "obj-15", 0 ],
									"source" : [ "obj-9", 0 ]
								}

							}
 ]
					}
,
					"patching_rect" : [ 235.0, 311.0, 73.0, 22.0 ],
					"saved_object_attributes" : 					{
						"description" : "",
						"digest" : "",
						"globalpatchername" : "",
						"tags" : ""
					}
,
					"text" : "p pixelMosh"
				}

			}
, 			{
				"box" : 				{
					"format" : 6,
					"id" : "obj-13",
					"maxclass" : "flonum",
					"numinlets" : 1,
					"numoutlets" : 2,
					"outlettype" : [ "", "bang" ],
					"parameter_enable" : 0,
					"patching_rect" : [ 213.0, 240.0, 50.0, 22.0 ]
				}

			}
, 			{
				"box" : 				{
					"bgmode" : 1,
					"border" : 1,
					"clickthrough" : 0,
					"enablehscroll" : 0,
					"enablevscroll" : 0,
					"id" : "obj-1",
					"lockeddragscroll" : 0,
					"lockedsize" : 0,
					"maxclass" : "bpatcher",
					"name" : "vs_render.maxpat",
					"numinlets" : 1,
					"numoutlets" : 1,
					"offset" : [ 0.0, 0.0 ],
					"outlettype" : [ "" ],
					"patching_rect" : [ 649.0, 477.0, 96.855263173580283, 146.5 ],
					"varname" : "vs_render",
					"viewvisibility" : 1
				}

			}
, 			{
				"box" : 				{
					"bgmode" : 1,
					"border" : 1,
					"clickthrough" : 0,
					"enablehscroll" : 0,
					"enablevscroll" : 0,
					"id" : "obj-2",
					"lockeddragscroll" : 0,
					"lockedsize" : 0,
					"maxclass" : "bpatcher",
					"name" : "vsc_presets.maxpat",
					"numinlets" : 1,
					"numoutlets" : 1,
					"offset" : [ 0.0, 0.0 ],
					"outlettype" : [ "" ],
					"patching_rect" : [ 749.0, 477.0, 171.0, 146.5 ],
					"varname" : "vs_presets",
					"viewvisibility" : 1
				}

			}
, 			{
				"box" : 				{
					"bgmode" : 1,
					"border" : 1,
					"clickthrough" : 0,
					"enablehscroll" : 0,
					"enablevscroll" : 0,
					"id" : "obj-4",
					"lockeddragscroll" : 0,
					"lockedsize" : 0,
					"maxclass" : "bpatcher",
					"name" : "vs_output.maxpat",
					"numinlets" : 1,
					"numoutlets" : 0,
					"offset" : [ 0.0, 0.0 ],
					"patching_rect" : [ 235.0, 375.0, 157.0, 22.0 ],
					"varname" : "vs_output",
					"viewvisibility" : 1
				}

			}
, 			{
				"box" : 				{
					"hidden" : 1,
					"id" : "obj-10",
					"linecount" : 2,
					"maxclass" : "newobj",
					"numinlets" : 1,
					"numoutlets" : 1,
					"outlettype" : [ "" ],
					"patching_rect" : [ 749.0, 537.0, 138.0, 35.0 ],
					"priority" : 					{
						"vs_wfg_2::wfg2_freq_range" : -1,
						"vs_wfg_2::wfg2_fm_range" : -1,
						"vs_wfg_2::wfg2_pm_range" : -1
					}
,
					"saved_object_attributes" : 					{
						"client_rect" : [ 854, 172, 1208, 300 ],
						"parameter_enable" : 0,
						"parameter_mappable" : 0,
						"storage_rect" : [ 766, 44, 1220, 302 ]
					}
,
					"text" : "pattrstorage @greedy 1 @changemode 1",
					"varname" : "Vsynth"
				}

			}
, 			{
				"box" : 				{
					"bgmode" : 1,
					"border" : 1,
					"clickthrough" : 0,
					"enablehscroll" : 0,
					"enablevscroll" : 0,
					"id" : "obj-6",
					"lockeddragscroll" : 0,
					"lockedsize" : 0,
					"maxclass" : "bpatcher",
					"name" : "vs_modules.maxpat",
					"numinlets" : 0,
					"numoutlets" : 0,
					"offset" : [ 0.0, 0.0 ],
					"patching_rect" : [ 8.0, 12.0, 79.0, 316.0 ],
					"viewvisibility" : 1
				}

			}
 ],
		"lines" : [ 			{
				"patchline" : 				{
					"destination" : [ "obj-18", 0 ],
					"source" : [ "obj-13", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-4", 0 ],
					"source" : [ "obj-18", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"color" : [ 0.65, 0.65, 0.65, 0.0 ],
					"destination" : [ "obj-10", 0 ],
					"hidden" : 1,
					"source" : [ "obj-2", 0 ]
				}

			}
, 			{
				"patchline" : 				{
					"destination" : [ "obj-18", 1 ],
					"source" : [ "obj-7", 0 ]
				}

			}
 ],
		"parameters" : 		{
			"obj-1::obj-19" : [ "dim_x[2]", "dim_x", 0 ],
			"obj-1::obj-23" : [ "pwm[1]", "pwm", 0 ],
			"obj-1::obj-36" : [ "live.text[11]", "live.text", 0 ],
			"obj-1::obj-40" : [ "live.text[6]", "live.text", 0 ],
			"obj-1::obj-41" : [ "dim_y[2]", "dim_y", 0 ],
			"obj-1::obj-42" : [ "dim_x[3]", "dim_x", 0 ],
			"obj-1::obj-45" : [ "live.text[10]", "live.text", 0 ],
			"obj-1::obj-48" : [ "live.text[7]", "live.text", 0 ],
			"obj-1::obj-5" : [ "live.text[9]", "live.text", 0 ],
			"obj-1::obj-6" : [ "live.text[8]", "live.text", 0 ],
			"obj-2::obj-10" : [ "vs_preset_name", "vs_preset_name", 0 ],
			"obj-2::obj-11" : [ "live.text", "live.text", 0 ],
			"obj-2::obj-15" : [ "live.tab", "live.tab", 0 ],
			"obj-2::obj-32" : [ "live.numbox", "live.numbox", 0 ],
			"obj-4::obj-1" : [ "toggle[1]", "toggle[1]", 0 ],
			"obj-4::obj-10" : [ "toggle[3]", "toggle[2]", 0 ],
			"obj-4::obj-36" : [ "uppr_x", "uppr_x", 0 ],
			"obj-6::obj-14" : [ "live.menu[20]", "live.menu", 0 ],
			"obj-6::obj-16" : [ "live.menu[32]", "live.menu", 0 ],
			"obj-6::obj-18" : [ "live.menu[28]", "live.menu", 0 ],
			"obj-6::obj-2" : [ "live.menu[29]", "live.menu", 0 ],
			"obj-6::obj-22" : [ "live.menu[31]", "live.menu", 0 ],
			"obj-6::obj-24" : [ "live.menu[26]", "live.menu", 0 ],
			"obj-6::obj-25" : [ "live.menu[24]", "live.menu", 0 ],
			"obj-6::obj-26" : [ "live.menu[22]", "live.menu", 0 ],
			"obj-6::obj-27" : [ "live.menu[19]", "live.menu", 0 ],
			"obj-6::obj-29" : [ "live.menu[33]", "live.menu", 0 ],
			"obj-6::obj-30" : [ "live.menu[30]", "live.menu", 0 ],
			"obj-6::obj-33" : [ "live.menu[27]", "live.menu", 0 ],
			"obj-6::obj-36" : [ "live.menu[23]", "live.menu", 0 ],
			"obj-6::obj-52" : [ "live.menu[25]", "live.menu", 0 ],
			"obj-6::obj-53" : [ "live.menu[18]", "live.menu", 0 ],
			"obj-6::obj-56" : [ "live.menu[21]", "live.menu", 0 ],
			"obj-7::obj-14::obj-12" : [ "flip_x[1]", "flip_x", 0 ],
			"obj-7::obj-14::obj-21" : [ "flip_y[1]", "flip_x", 0 ],
			"obj-7::obj-14::obj-22" : [ "swap[1]", "flip_x", 0 ],
			"obj-7::obj-14::obj-3" : [ "sync_invert[1]", "sync_inv", 0 ],
			"obj-7::obj-14::obj-4" : [ "live.text[12]", "live.text", 0 ],
			"obj-7::obj-15::obj-28" : [ "sync_invert", "sync_inv", 0 ],
			"obj-7::obj-15::obj-42" : [ "number", "number", 0 ],
			"obj-7::obj-24::obj-11" : [ "sync_invert[3]", "sync_inv", 0 ],
			"obj-7::obj-24::obj-19" : [ "noise2_dim_x[1]", "dim_x", 0 ],
			"obj-7::obj-24::obj-2" : [ "noise2_dim_x", "dim_x", 0 ],
			"obj-7::obj-24::obj-35" : [ "live.dial", "Speed", 0 ],
			"obj-7::obj-24::obj-43" : [ "temp_freq", "Slide", 0 ],
			"obj-7::obj-24::obj-8" : [ "sync_invert[2]", "sync_inv", 0 ],
			"obj-7::obj-4::obj-1" : [ "live.text[13]", "sync_inv", 0 ],
			"obj-7::obj-4::obj-10" : [ "wfg_pw", "PW", 0 ],
			"obj-7::obj-4::obj-137" : [ "wfg_wf", "waveform", 0 ],
			"obj-7::obj-4::obj-139" : [ "sync_pos", "position", 0 ],
			"obj-7::obj-4::obj-29" : [ "wfg_freq", "Freq", 0 ],
			"obj-7::obj-4::obj-3" : [ "sync_time", "Time", 0 ],
			"obj-7::obj-4::obj-4" : [ "wfg_freq[1]", "Phase", 0 ],
			"obj-7::obj-4::obj-60" : [ "clrizer_color[1]", "color", 0 ],
			"obj-7::obj-9::obj-13" : [ "myGrads", "live.menu", 0 ],
			"obj-7::obj-9::obj-17" : [ "live.numbox[1]", "live.numbox", 0 ],
			"obj-7::obj-9::obj-22" : [ "clpick", "live.text", 0 ],
			"obj-7::obj-9::obj-34" : [ "live.tab[1]", "live.tab", 0 ],
			"parameterbanks" : 			{

			}
,
			"parameter_overrides" : 			{
				"obj-6::obj-14" : 				{
					"parameter_longname" : "live.menu[20]"
				}
,
				"obj-6::obj-16" : 				{
					"parameter_longname" : "live.menu[32]"
				}
,
				"obj-6::obj-18" : 				{
					"parameter_longname" : "live.menu[28]"
				}
,
				"obj-6::obj-2" : 				{
					"parameter_longname" : "live.menu[29]"
				}
,
				"obj-6::obj-22" : 				{
					"parameter_longname" : "live.menu[31]"
				}
,
				"obj-6::obj-24" : 				{
					"parameter_longname" : "live.menu[26]"
				}
,
				"obj-6::obj-25" : 				{
					"parameter_longname" : "live.menu[24]"
				}
,
				"obj-6::obj-26" : 				{
					"parameter_longname" : "live.menu[22]"
				}
,
				"obj-6::obj-27" : 				{
					"parameter_longname" : "live.menu[19]"
				}
,
				"obj-6::obj-29" : 				{
					"parameter_longname" : "live.menu[33]"
				}
,
				"obj-6::obj-30" : 				{
					"parameter_longname" : "live.menu[30]"
				}
,
				"obj-6::obj-33" : 				{
					"parameter_longname" : "live.menu[27]"
				}
,
				"obj-6::obj-36" : 				{
					"parameter_longname" : "live.menu[23]"
				}
,
				"obj-6::obj-52" : 				{
					"parameter_longname" : "live.menu[25]"
				}
,
				"obj-6::obj-53" : 				{
					"parameter_longname" : "live.menu[18]"
				}
,
				"obj-6::obj-56" : 				{
					"parameter_longname" : "live.menu[21]"
				}
,
				"obj-7::obj-24::obj-11" : 				{
					"parameter_longname" : "sync_invert[3]"
				}
,
				"obj-7::obj-24::obj-8" : 				{
					"parameter_longname" : "sync_invert[2]"
				}
,
				"obj-7::obj-4::obj-1" : 				{
					"parameter_longname" : "live.text[13]"
				}
,
				"obj-7::obj-9::obj-17" : 				{
					"parameter_longname" : "live.numbox[1]"
				}
,
				"obj-7::obj-9::obj-34" : 				{
					"parameter_longname" : "live.tab[1]"
				}

			}
,
			"inherited_shortname" : 1
		}
,
		"dependency_cache" : [ 			{
				"name" : "A.png",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/media",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/media",
				"type" : "PNG",
				"implicit" : 1
			}
, 			{
				"name" : "B.png",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/media",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/media",
				"type" : "PNG",
				"implicit" : 1
			}
, 			{
				"name" : "C.png",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/media",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/media",
				"type" : "PNG",
				"implicit" : 1
			}
, 			{
				"name" : "D.png",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/media",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/media",
				"type" : "PNG",
				"implicit" : 1
			}
, 			{
				"name" : "E.png",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/media",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/media",
				"type" : "PNG",
				"implicit" : 1
			}
, 			{
				"name" : "F.png",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/media",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/media",
				"type" : "PNG",
				"implicit" : 1
			}
, 			{
				"name" : "G.png",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/media",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/media",
				"type" : "PNG",
				"implicit" : 1
			}
, 			{
				"name" : "addmod.js",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/javascript",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/javascript",
				"type" : "TEXT",
				"implicit" : 1
			}
, 			{
				"name" : "jit.mo.time.mxo",
				"type" : "iLaX"
			}
, 			{
				"name" : "moduleSize.js",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/javascript",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/javascript",
				"type" : "TEXT",
				"implicit" : 1
			}
, 			{
				"name" : "sources_cam.maxpat",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/patchers/vs_sources",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/patchers/vs_sources",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "sources_color.maxpat",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/patchers/vs_sources",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/patchers/vs_sources",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "sources_movie.maxpat",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/patchers/vs_sources",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/patchers/vs_sources",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "sources_noise.maxpat",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/patchers/vs_sources",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/patchers/vs_sources",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "sources_oscillator.maxpat",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/patchers/vs_sources",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/patchers/vs_sources",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "timediv.txt",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/patchers",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/patchers",
				"type" : "TEXT",
				"implicit" : 1
			}
, 			{
				"name" : "vs_modules.maxpat",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/patchers",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/patchers",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "vs_output.maxpat",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/patchers",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/patchers",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "vs_render.maxpat",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/patchers",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/patchers",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "vs_sources_main.maxpat",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/patchers/vs_sources",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/patchers/vs_sources",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "vsc_presets.maxpat",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/patchers/Weird",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/patchers/Weird",
				"type" : "JSON",
				"implicit" : 1
			}
, 			{
				"name" : "vsdown.svg",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/media",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/media",
				"type" : "svg",
				"implicit" : 1
			}
, 			{
				"name" : "vssaw.svg",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/media",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/media",
				"type" : "svg",
				"implicit" : 1
			}
, 			{
				"name" : "vssine.svg",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/media",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/media",
				"type" : "svg",
				"implicit" : 1
			}
, 			{
				"name" : "vssquare.svg",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/media",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/media",
				"type" : "svg",
				"implicit" : 1
			}
, 			{
				"name" : "vsup.svg",
				"bootpath" : "~/Documents/Max 8/Packages/Vsynth/media",
				"patcherrelativepath" : "../../Documents/Max 8/Packages/Vsynth/media",
				"type" : "svg",
				"implicit" : 1
			}
 ],
		"autosave" : 0,
		"boxgroups" : [ 			{
				"boxes" : [ "obj-2", "obj-10" ]
			}
 ]
	}

}
