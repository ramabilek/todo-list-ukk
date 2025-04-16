<?php

namespace App\Http\Controllers;

use App\Models\Lists;
use Illuminate\Http\Request;

class ListsController extends Controller
{
    /**
     * Display a listing of the resource.
     */
    public function index()
    {
        return Lists::all();
    }
    
    public function create(Request $req)
    {
        $lists = $req->validate([
            'name' => 'required|string',
        ]);
        
        Lists::create($lists);
        return response()->json(['message' => 'data created', 'list' => $lists]);
    }


    public function update(Request $req, $id)
    {
        $lists = Lists::find($id);
        if (!$lists){
            return response()->json(['message' => 'data not found']);
        }

        $data = $req->validate([
            'name' => 'required|string',
        ]);

        $lists->update($data);
        return response()->json(['message' => 'data updated', 'list' => $lists]);
    }


    public function delete($id)
    {
        $lists = Lists::find($id);
        if (!$lists){
            return response()->json(['message' => 'data not found']);
        }

        $lists->delete();
        return response()->json(['message' => 'data deleted']);
    }
}
