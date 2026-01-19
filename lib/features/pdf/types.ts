
export interface ServiceReportData {
    reportNo: string;
    date: string;
    wod: string;
    contract: 'Yes' | 'No';
    customerParticular: string;
    ckNo: string;
    brand: string;
    typeOfEquipment: string;
    equipmentId: string;
    lastPm: string;
    location: string;
    serviceType: string;
    hourMeter: string;
    customerRequest: string;
    diagnosis: string;
    partSupplies: PartSupply[];
    measurements: string;
    problemFixed: 'Yes' | 'No';
    attachedReport: 'Yes' | 'No';
    nop: string;
    technicianRecommendation: string;
    pictures: PictureReport[];
    technicians: TechnicianEntry[];
    customerFeedback: {
      name: string;
      position: string;
      date: string;
      signature: string;
      comments: string;
    };
  }
  
  export interface PartSupply {
    id: string;
    description: string;
  }
  
  export interface PictureReport {
    id: number;
    label: string;
    imageUrl: string | null;
  }
  
  export interface TechnicianEntry {
    id: string;
    names: string;
    dateArrived: string;
    timeArrived: string;
    dateCompleted: string;
    timeCompleted: string;
    totalHour: string;
  }
  