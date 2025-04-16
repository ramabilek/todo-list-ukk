<?php

use App\Http\Controllers\ListsController;
use App\Http\Controllers\TasksController;
use Illuminate\Http\Request;
use Illuminate\Support\Facades\Route;

/*
|--------------------------------------------------------------------------
| API Routes
|--------------------------------------------------------------------------
|
| Here is where you can register API routes for your application. These
| routes are loaded by the RouteServiceProvider and all of them will
| be assigned to the "api" middleware group. Make something great!
|
*/

Route::get('lists/get', [ListsController::class, 'index']);
Route::post('lists/create', [ListsController::class, 'create']);
Route::post('lists/update/{id}', [ListsController::class, 'update']);
Route::delete('lists/delete/{id}', [ListsController::class, 'delete']);

Route::get('tasks/get', [TasksController::class, 'index']);
Route::post('tasks/create', [TasksController::class, 'create']);
Route::post('tasks/update/{id}', [TasksController::class, 'update']);
Route::delete('tasks/delete/{id}', [TasksController::class, 'delete']);