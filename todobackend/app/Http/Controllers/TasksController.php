<?php

namespace App\Http\Controllers;

use App\Models\Tasks;
use Illuminate\Console\View\Components\Task;
use Illuminate\Http\Request;

class TasksController extends Controller
{
    public function index()
    {
        return response()->json(Tasks::all());
    }


    public function create(Request $req)
    {
        $tasks = $req->validate([
            'name' => 'required|string',
            'deadline' => 'required|date_format:H:i',
            'status' => 'required|in:in progress,completed',
            'list_id' => 'exists:lists,id'
        ]);
        
        Tasks::create($tasks);
        return response()->json(['message' => 'data created', 'tasks' => $tasks]);
    }

    public function update(Request $req, $id)
    {
        $tasks = Tasks::find($id);
        if (!$tasks){
            return response()->json(['message' => 'data not found']);
        }

        $data = $req->validate([
            'name' => 'sometimes|string',
            'deadline' => 'sometimes|date_format:H:i',
            'status' => 'sometimes|in:in progress,completed',
            'list_id' => 'sometimes|exists:lists,id'
        ]);

        $tasks->update($data);
        return response()->json(['message' => 'data updated', 'lists' => $data]);
    }


    public function delete($id)
    {
        $tasks = Tasks::find($id);
        if (!$tasks){
            return response()->json(['message' => 'data not found']);
        }

        $tasks->delete();
        return response()->json(['message' => 'data deleted']);
    }
}
