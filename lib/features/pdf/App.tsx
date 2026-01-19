
import React, { useState, useRef } from 'react';
import { 
  Printer, 
  Save, 
  Plus, 
  Trash2, 
  Camera, 
  Wrench,
  CheckCircle2,
  PenTool
} from 'lucide-react';
import { ServiceReportData, PartSupply, PictureReport, TechnicianEntry } from './types';

const INITIAL_STATE: ServiceReportData = {
  reportNo: 'SR000235',
  date: '31-Oct-25',
  wod: 'T6718/23LIPP',
  contract: 'Yes',
  customerParticular: 'Moi',
  ckNo: '',
  brand: '',
  typeOfEquipment: 'Escalator Service',
  equipmentId: 'Eq44915440',
  lastPm: '31-Oct-25',
  location: 'ESC 20',
  serviceType: 'Maintenance',
  hourMeter: 'N/A',
  customerRequest: 'Maintenance Escalator',
  diagnosis: 'Maintenance Escalator - The ESC working normally\n_Test switch comb plate and test switch all\n_Check step guide rails and spring\n_Check gap between scraping step to step say\n_Clean pit and step inside all',
  partSupplies: [{ id: '1', description: '' }],
  measurements: '',
  problemFixed: 'Yes',
  attachedReport: 'No',
  nop: '',
  technicianRecommendation: '',
  pictures: [
    { id: 1, label: 'Check control panel', imageUrl: 'https://picsum.photos/400/300?random=1' },
    { id: 2, label: 'Check break motor', imageUrl: 'https://picsum.photos/400/300?random=2' },
    { id: 3, label: 'Check drive chain', imageUrl: 'https://picsum.photos/400/300?random=3' },
    { id: 4, label: 'Check switch', imageUrl: 'https://picsum.photos/400/300?random=4' },
  ],
  technicians: [
    { 
      id: '1', 
      names: 'Ratanak+ khoeun', 
      dateArrived: '31-Oct-25', 
      timeArrived: '17:00',
      dateCompleted: '31-Oct-25',
      timeCompleted: '22:00',
      totalHour: '5:00'
    }
  ],
  customerFeedback: {
    name: '',
    position: '',
    date: '',
    signature: '',
    comments: ''
  }
};

const FormField: React.FC<{ label: string; khmerLabel: string; value: string; onChange: (v: string) => void; className?: string; inputClassName?: string }> = ({ label, khmerLabel, value, onChange, className = "", inputClassName = "" }) => (
  <div className={`flex flex-col border-r border-b border-black p-1.5 min-h-[42px] justify-center ${className}`}>
    <div className="flex items-center gap-1.5 text-[9px] leading-tight font-bold uppercase tracking-tight text-black">
      <span className="khmer-font text-[10px] font-normal leading-none">{khmerLabel}</span>
      <span className="text-gray-400 font-normal">/</span>
      <span>{label}</span>
    </div>
    <input 
      type="text" 
      value={value} 
      onChange={(e) => onChange(e.target.value)}
      className={`w-full text-[11px] italic font-semibold outline-none text-blue-800 mt-0.5 bg-transparent border-none p-0 focus:ring-0 ${inputClassName}`}
    />
  </div>
);

const SectionHeader: React.FC<{ khmer: string; english: string; className?: string }> = ({ khmer, english, className = "" }) => (
  <div className={`bg-[#BCE6B4] p-1.5 px-3 font-bold flex items-center gap-2 border-b border-black text-[10px] ${className}`}>
    <span className="khmer-font text-[11px] font-medium leading-none">{khmer}</span>
    <span className="text-black/30 font-normal">/</span>
    <span className="uppercase tracking-wide text-black">{english}</span>
  </div>
);

const App: React.FC = () => {
  const [data, setData] = useState<ServiceReportData>(INITIAL_STATE);
  const [isSaved, setIsSaved] = useState(false);
  const fileInputRefs = useRef<{ [key: number]: HTMLInputElement | null }>({});

  const handlePrint = () => {
    window.print();
  };

  const handleSave = () => {
    setIsSaved(true);
    setTimeout(() => setIsSaved(false), 3000);
  };

  const updateField = (field: keyof ServiceReportData, value: any) => {
    setData(prev => ({ ...prev, [field]: value }));
  };

  const handleImageUpload = (id: number, e: React.ChangeEvent<HTMLInputElement>) => {
    const file = e.target.files?.[0];
    if (file) {
      const reader = new FileReader();
      reader.onloadend = () => {
        setData(prev => ({
          ...prev,
          pictures: prev.pictures.map(p => p.id === id ? { ...p, imageUrl: reader.result as string } : p)
        }));
      };
      reader.readAsDataURL(file);
    }
  };

  return (
    <div className="min-h-screen p-4 md:p-8 flex flex-col items-center bg-[#F3F4F6] font-sans selection:bg-blue-100">
      {/* Dynamic Action Bar */}
      <div className="no-print w-full max-w-[210mm] flex justify-between items-center mb-6 bg-white p-4 rounded-xl shadow-md border border-gray-200 sticky top-4 z-50">
        <div className="flex items-center gap-3">
          <div className="bg-emerald-600 p-2 rounded-lg shadow-sm">
            <Wrench className="text-white w-5 h-5" />
          </div>
          <div>
            <h1 className="text-base font-bold text-gray-900 leading-none">Field Service Portal</h1>
            <p className="text-[9px] text-gray-500 font-bold uppercase tracking-widest mt-1">Live Document</p>
          </div>
        </div>
        <div className="flex gap-3">
          <button 
            onClick={handleSave}
            className={`flex items-center gap-2 px-5 py-2 rounded-lg transition-all font-bold text-sm ${isSaved ? 'bg-emerald-500 text-white' : 'bg-blue-600 hover:bg-blue-700 text-white shadow-sm'}`}
          >
            {isSaved ? <CheckCircle2 className="w-4 h-4" /> : <Save className="w-4 h-4" />}
            {isSaved ? 'Saved' : 'Save Draft'}
          </button>
          <button 
            onClick={handlePrint}
            className="flex items-center gap-2 bg-gray-900 hover:bg-black text-white px-5 py-2 rounded-lg transition-all font-bold text-sm shadow-sm"
          >
            <Printer className="w-4 h-4" /> Export PDF
          </button>
        </div>
      </div>

      {/* Report Page Sheet */}
      <div className="report-container w-full max-w-[210mm] bg-white print-shadow-none shadow-2xl p-6 md:p-10 border border-gray-300 min-h-[297mm] flex flex-col text-[11px] text-black ring-1 ring-black/5">
        
        {/* Header Section */}
        <div className="grid grid-cols-12 gap-0 mb-3 shrink-0">
          <div className="col-span-5 flex flex-col">
            <div className="flex items-center gap-3 mb-1.5">
              <div className="w-10 h-10 border-[3px] border-black rounded-full flex items-center justify-center p-1">
                <div className="w-full h-full border-[2px] border-emerald-500 rounded-full flex items-center justify-center">
                  <div className="w-1.5 h-1.5 bg-emerald-500 rounded-full"></div>
                </div>
              </div>
              <div className="leading-none">
                <span className="text-2xl font-black tracking-tighter text-black block">CominKhmere</span>
              </div>
            </div>
            <h2 className="text-base font-bold flex items-center gap-2">
              <span className="khmer-font text-lg leading-none">របាយការណ៍សេវាកម្ម</span>
              <span className="text-gray-300">/</span>
              <span className="uppercase tracking-tight text-sm">Service Report</span>
            </h2>
          </div>
          
          <div className="col-span-3 flex flex-col justify-end items-center pb-2">
             <div className="font-bold text-sm">
               No: <span className="font-black text-red-600 ml-1 font-mono">{data.reportNo}</span>
             </div>
          </div>
          
          <div className="col-span-4 text-right">
            <div className="font-bold text-[9px] mb-1 text-gray-500 uppercase tracking-widest">Hotline</div>
            <div className="text-[8px] leading-tight font-bold text-black italic">
              <div>PP: 012 816 800 / SHV: 092 777 224</div>
              <div>SR: 012 222 723 / PPIA: 092 777 143</div>
              <div>SVIA: 092 666 791</div>
            </div>
          </div>
        </div>

        {/* Info Grid - Fixed Intersections */}
        <div className="border-t border-l border-black shrink-0">
          <div className="grid grid-cols-12">
            <FormField className="col-span-4" khmerLabel="កាលបរិច្ឆេទ" label="Date" value={data.date} onChange={(v) => updateField('date', v)} />
            <FormField className="col-span-4" khmerLabel="WOD" label="WOD" value={data.wod} onChange={(v) => updateField('wod', v)} />
            <div className="col-span-4 border-r border-b border-black p-1.5 flex items-center justify-end pr-4 font-black text-[10px]">
              CONTRACT: <span className="text-blue-700 ml-2 italic underline decoration-blue-200">{data.contract}</span>
            </div>

            <FormField className="col-span-6" khmerLabel="ឈ្មោះអតិថិជន" label="Customer particular" value={data.customerParticular} onChange={(v) => updateField('customerParticular', v)} />
            <FormField className="col-span-6" khmerLabel="លេខសម្គាល់" label="CK no" value={data.ckNo} onChange={(v) => updateField('ckNo', v)} />

            <div className="col-span-6 border-r border-b border-black bg-gray-50/20"></div>
            <FormField className="col-span-6" khmerLabel="ម៉ាក" label="Brand" value={data.brand} onChange={(v) => updateField('brand', v)} />

            <FormField className="col-span-6" khmerLabel="ប្រភេទបរិក្ខារ" label="Type of Equipment" value={data.typeOfEquipment} onChange={(v) => updateField('typeOfEquipment', v)} />
            <FormField className="col-span-6" khmerLabel="បរិក្ខារ" label="Equipment" value={data.equipmentId} onChange={(v) => updateField('equipmentId', v)} />

            <FormField className="col-span-6" khmerLabel="ថ្ងៃថែទាំចុងក្រោយ" label="last PM" value={data.lastPm} onChange={(v) => updateField('lastPm', v)} />
            <FormField className="col-span-6" khmerLabel="ទីតាំង" label="Location" value={data.location} onChange={(v) => updateField('location', v)} />

            <FormField className="col-span-6" khmerLabel="ប្រភេទសេវាកម្ម" label="Service type" value={data.serviceType} onChange={(v) => updateField('serviceType', v)} />
            <FormField className="col-span-6" khmerLabel="កុងទ័រម៉ោង" label="Hour Meter" value={data.hourMeter} onChange={(v) => updateField('hourMeter', v)} />
          </div>
        </div>

        {/* Customer Request Section */}
        <div className="border-x border-black shrink-0">
          <SectionHeader khmer="ការស្នើសុំ ស្ទើពីអតិថិជន" english="Customer Request" />
          <div className="p-2 min-h-[40px] border-b border-black bg-white text-blue-800 italic font-semibold text-[11px] flex items-center">
            <input 
              className="w-full outline-none bg-transparent" 
              value={data.customerRequest}
              onChange={(e) => updateField('customerRequest', e.target.value)}
            />
          </div>
        </div>

        {/* Diagnosis Section */}
        <div className="border-x border-black shrink-0">
          <SectionHeader khmer="ការវិនិច្ឆ័យកំហូច ឬការថែទាំជូន សេវាកម្មដែលបានផ្ដល់ជូន" english="Diagnosis Defect Found / Service Rendered" />
          <div className="p-3 min-h-[120px] border-b border-black bg-white">
             <textarea 
              className="w-full resize-none outline-none italic text-blue-800 leading-snug font-semibold text-[11px] bg-transparent" 
              value={data.diagnosis}
              rows={5}
              onChange={(e) => updateField('diagnosis', e.target.value)}
            />
          </div>
        </div>

        {/* Parts & Measurements Table */}
        <div className="border-x border-black shrink-0">
          <div className="grid grid-cols-2 border-b border-black">
            <div className="border-r border-black flex flex-col">
              <SectionHeader khmer="គ្រឿងបន្លាស់" english="Part Supply" />
              <div className="p-2 min-h-[100px] flex flex-col gap-1 bg-white">
                {data.partSupplies.map((part, idx) => (
                  <div key={part.id} className="flex gap-2 items-center group">
                     <input 
                      className="flex-1 outline-none text-blue-800 font-semibold text-[11px] italic px-2 py-0.5 border-b border-transparent focus:border-blue-100" 
                      placeholder="..."
                      value={part.description}
                      onChange={(e) => {
                        const newList = [...data.partSupplies];
                        newList[idx].description = e.target.value;
                        updateField('partSupplies', newList);
                      }}
                    />
                    <button onClick={() => {
                      const newList = data.partSupplies.filter(p => p.id !== part.id);
                      updateField('partSupplies', newList);
                    }} className="text-red-500 no-print pr-1">
                      <Trash2 className="w-3.5 h-3.5" />
                    </button>
                  </div>
                ))}
                <button 
                  className="no-print mt-auto text-[9px] text-emerald-700 font-black flex items-center gap-1 hover:text-emerald-900 transition-colors"
                  onClick={() => updateField('partSupplies', [...data.partSupplies, { id: Math.random().toString(), description: '' }])}
                >
                  <Plus className="w-3 h-3" /> ADD
                </button>
              </div>
            </div>
            <div className="flex flex-col">
              <div className="bg-[#BCE6B4] p-1.5 px-3 font-bold border-b border-black text-[10px]">
                 Measurements & Test Conducted (Tool serial.............)
              </div>
              <div className="p-2 min-h-[100px] relative bg-white flex flex-col">
                <textarea 
                  className="w-full flex-1 resize-none outline-none italic text-blue-800 font-semibold text-[11px] bg-transparent" 
                  value={data.measurements}
                  onChange={(e) => updateField('measurements', e.target.value)}
                />
                <div className="mt-auto border-t border-gray-100 pt-1 flex justify-end gap-2 items-center font-black text-[9px] uppercase tracking-tighter">
                   <span className="khmer-font normal-case font-bold text-[10px]">កំហុសត្រូវបានជួសជុល</span>
                   <span className="text-gray-400">/</span>
                   PROBLEM FIXED: 
                   <span className="text-blue-700 ml-1 italic">{data.problemFixed}</span>
                </div>
              </div>
            </div>
          </div>
        </div>

        {/* Attached Report & Comments Row */}
        <div className="border-x border-black shrink-0">
          <div className="grid grid-cols-2 border-b border-black">
            <div className="border-r border-black">
              <div className="border-b border-black p-2 flex justify-center items-center italic font-black text-[10px] uppercase">
                <span className="khmer-font not-italic normal-case mr-2 font-bold text-[11px]">របាយការណ៍ភ្ជាប់</span>
                <span className="text-gray-400 mr-2">/</span>
                ATTACHED REPORT: 
                <span className="text-blue-700 ml-3">{data.attachedReport}</span>
              </div>
              <div className="p-2 flex justify-center items-center font-black text-[10px] uppercase">
                <span className="khmer-font mr-2 font-bold text-[11px]">ចំនួនទំព័រ</span>
                <span className="text-gray-400 mr-2">/</span>
                NOP:
                <input 
                  type="text" 
                  className="w-12 ml-2 text-center outline-none text-blue-700 font-black italic border-b border-blue-100" 
                  value={data.nop}
                  onChange={(e) => updateField('nop', e.target.value)}
                />
              </div>
            </div>
            <div className="p-2 italic text-[9px] leading-tight font-black bg-white">
               <div className="flex items-center gap-1.5 mb-1 uppercase tracking-tight">
                 <span className="khmer-font not-italic font-bold text-[10px] normal-case">បញ្ជាក់ពីមូលហេតុដែលមិនត្រូវបានជួសជុល</span>
                 <span className="text-gray-400">/</span>
                 if not fixed, mention why:
               </div>
               <textarea 
                className="w-full h-[40px] resize-none outline-none border-none text-blue-800 italic font-semibold text-[11px] bg-transparent"
                value={data.customerFeedback.comments}
                onChange={(e) => updateField('customerFeedback', { ...data.customerFeedback, comments: e.target.value })}
              />
            </div>
          </div>
        </div>

        {/* Recommendation Section */}
        <div className="border-x border-black shrink-0">
          <div className="p-1.5 px-3 font-black text-[9px] bg-gray-50 uppercase tracking-widest border-b border-black text-gray-400 italic">
            Technician Recommendation:
          </div>
          <div className="p-2 min-h-[40px] border-b border-black bg-white text-blue-800 italic font-semibold flex items-center text-[11px]">
            <input 
              className="w-full outline-none bg-transparent" 
              value={data.technicianRecommendation}
              onChange={(e) => updateField('technicianRecommendation', e.target.value)}
            />
          </div>
        </div>

        {/* Picture Report Section */}
        <div className="border-x border-black shrink-0">
          <SectionHeader khmer="រូបភាពរបាយការណ៍" english="Picture Report" />
          <div className="grid grid-cols-4 h-[140px] bg-gray-50 border-b border-black">
            {data.pictures.map((pic) => (
              <div 
                key={pic.id} 
                className="border-r border-black last:border-r-0 relative flex flex-col cursor-pointer group hover:bg-white transition-all overflow-hidden"
                onClick={() => fileInputRefs.current[pic.id]?.click()}
              >
                <div className="flex-1 flex items-center justify-center relative">
                  {pic.imageUrl ? (
                    <img src={pic.imageUrl} alt={pic.label} className="w-full h-full object-cover" />
                  ) : (
                    <Camera className="w-6 h-6 text-gray-300 group-hover:text-blue-400 transition-colors" />
                  )}
                  <input 
                    ref={el => { if (el) fileInputRefs.current[pic.id] = el; }}
                    type="file" 
                    accept="image/*" 
                    className="hidden" 
                    onChange={(e) => handleImageUpload(pic.id, e)}
                  />
                </div>
                <div className="p-1.5 border-t border-black text-[9px] italic text-blue-800 bg-white font-black text-center truncate tracking-tight uppercase">
                  {pic.label}
                </div>
              </div>
            ))}
          </div>
        </div>

        {/* Personnel & Signature Section Header */}
        <div className="border-x border-black shrink-0">
          <div className="grid grid-cols-12 bg-[#BCE6B4] border-b border-black h-9 relative z-10">
            <div className="col-span-6 border-r border-black px-3 flex items-center font-black text-[9px] uppercase tracking-tighter">
              <span className="khmer-font mr-2 text-[11px] font-bold normal-case">ជាងបច្ចេកទេស</span>
              <span className="text-gray-400 mr-2">/</span>
              List of Technician
            </div>
            <div className="col-span-6 px-3 flex items-center justify-center font-black text-[9px] uppercase tracking-tighter text-center">
              Customer: Name, Position, Date, Signature & Comments
            </div>
          </div>

          <div className="grid grid-cols-12 border-b border-black min-h-[160px]">
            {/* Technician Table Rows */}
            <div className="col-span-6 border-r border-black flex flex-col bg-white">
              <table className="w-full text-[10px] border-collapse h-full">
                <tbody className="divide-y divide-black">
                  <tr>
                    <td className="px-3 border-r border-black font-black text-[9px] w-1/3 py-2 uppercase tracking-tighter bg-gray-50/30">
                      <span className="khmer-font normal-case font-bold text-[10px] block">ឈ្មោះ</span> Names
                    </td>
                    <td className="px-3 text-blue-800 font-black italic text-[11px] py-2">{data.technicians[0].names}</td>
                  </tr>
                  <tr>
                    <td className="px-3 border-r border-black font-black text-[9px] py-2 uppercase tracking-tighter bg-gray-50/30">Date & Time Arrived</td>
                    <td className="px-3 flex justify-between items-center text-blue-800 font-black italic text-[11px] py-2">
                      <span>{data.technicians[0].dateArrived}</span>
                      <span>{data.technicians[0].timeArrived}</span>
                    </td>
                  </tr>
                  <tr>
                    <td className="px-3 border-r border-black font-black text-[9px] py-2 uppercase tracking-tighter bg-gray-50/30">Date & Time Completed</td>
                    <td className="px-3 flex justify-between items-center text-blue-800 font-black italic text-[11px] py-2">
                      <span>{data.technicians[0].dateCompleted}</span>
                      <span>{data.technicians[0].timeCompleted}</span>
                    </td>
                  </tr>
                  <tr>
                    <td className="px-3 border-r border-black font-black text-[9px] py-3 uppercase tracking-tighter bg-gray-50/30">Total Hour</td>
                    <td className="px-3 text-blue-800 font-black italic text-[11px] py-3">{data.technicians[0].totalHour}</td>
                  </tr>
                </tbody>
              </table>
            </div>

            {/* Signature Area */}
            <div className="col-span-6 bg-white flex flex-col p-4 relative cursor-crosshair">
              <div className="flex-1 border-2 border-dashed border-gray-100 rounded-xl flex flex-col items-center justify-center gap-2">
                 <PenTool className="w-8 h-8 text-gray-100" />
                 <span className="text-[9px] font-black text-gray-200 uppercase tracking-widest">Sign Above</span>
              </div>
            </div>
          </div>
        </div>

        {/* Final Meta Footer Rows */}
        <div className="border-x border-black shrink-0">
          <div className="grid grid-cols-12 text-[9px] font-black h-9 bg-gray-50 border-b border-black shrink-0 uppercase tracking-tighter items-center">
            <div className="col-span-4 px-4 border-r border-black h-full flex items-center">CK USE: ........................</div>
            <div className="col-span-4 h-full flex items-center justify-center border-r border-black">CHECK BY: ........................</div>
            <div className="col-span-4 h-full flex items-center justify-end px-4">CHECKED ON: ........................</div>
          </div>
        </div>

        {/* Document Tracking Metadata */}
        <div className="mt-4 grid grid-cols-2 shrink-0">
          <div className="text-[9px] font-bold text-gray-500 leading-snug tracking-wider">
            <div>FORM NO: CK-SDD-F-0042</div>
            <div>REVISION: 2</div>
            <div>DATED: 12-AUG-2025</div>
          </div>
          <div className="text-right flex flex-col justify-end">
            <div className="text-[8px] font-black text-emerald-600 uppercase tracking-widest italic opacity-50">Precision Digital Twin</div>
          </div>
        </div>
      </div>
      
      {/* Branding Footer */}
      <div className="no-print mt-6 text-[10px] text-gray-400 font-bold italic uppercase tracking-widest mb-10">
        * CominKhmere Digital Core
      </div>
    </div>
  );
};

export default App;